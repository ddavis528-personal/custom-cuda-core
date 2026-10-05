<!-- design-snapshot url=https://claude.ai/artifact/EcuSx6yXG4dCmkT2ky2Cb7 tab=Changes rev=87 exported=2026-10-04 status=closed -->
> **Snapshot: do not edit.** Exported from *Interface spec changes — OOE session*, tab *Changes*, at revision 87 on 2026-10-04 ([live doc](https://claude.ai/artifact/EcuSx6yXG4dCmkT2ky2Cb7)). The live doc is the source; it is a closed record, whose conversation has ended. This copy pins what the repo was built against; see [README.md](README.md).

# Interface spec changes — OOE session

Sep 28, 2026 · @Daniel Davis

## Purpose

The OOE grill-me changes seven channels, removes one allocation role from RAU, and adds one new OOE-to-RCU path. This doc lists only those deltas, so the arch agent can apply them to the high-level interface spec and the schema (`schema/interfaces.json`).

**Applied 2026-10-02** in custom-cuda-core `3543276`; the full verify gate passes. Every change on this tab is in `schema/interfaces.json` and `params/ccv_params.json`, with the stubs and the checker bank following. Where the applied form differs from this tab, or goes beyond it:

- **Checkpoint width name.** It is `CCV_P_W_CKPT_ID` (provisional), not `CCV_W_CKPT_ID` (settled). The parameter generator now refuses a derived width that is more settled than its inputs, and this one follows `CCV_P_BR_CKPTS`.
- **`ccv_ooe_rcu_map` has no declared slot attributes.** The schema refuses them on a rate-1 channel because they describe nothing there: a single slot is already atomic and ordered. Its doc says so.
- **Predicate rename parameters** are named `CCV_P_PRED_REN_FLOOR`, `CCV_P_PRED_REN_CEIL` and `CCV_P_PRED_REN_SLACK`, beside `CCV_P_REN_SLACK` for GPRs. The floors and ceilings are derived from the pools and checked on every build.
- **Generated latencies** are measured from a stated reference point. `CCV_LAT_LANE` runs from RCU accepting the issue (base + `rcu_lane_ops` + `lane_rcu_res` stages). `CCV_LAT_L1_HIT` runs from MIU accepting the memop (base + `miu_dcu_req` + `dcu_miu_rsp` stages). `CCV_LAT_RCU` crosses no link. Confirmed by the session (A-57), with two additions not yet applied: generated CCV\_LAT\_L1\_WAKE and CCV\_LAT\_L1\_CMPL, and CCV\_LAT\_LANE\_BYP defined as lane-local: the 4-cycle base with no link terms, from issue to dependent issue, plus a per-op-class bypassable flag, since cross-lane ops wake dependants at the full CCV\_LAT\_LANE (A-59).
- **Fixed latency** is the schema slot attribute `fixed_latency`. The credit checker enforces it with `fixed_latency_no_stall` and `fixed_latency_prompt` on all 272 slots of the six channels. The arrival-cycle, outstanding-tag, A-35 and pairing checkers need a block's internals and are scheduled with their blocks (repo Q-53).
- **Found while applying:** a correctly predicted branch has no way to free its checkpoint (A-56, repo Q-52). Resolved by the new ccv\_ooe\_fet\_ckpt\_free channel, applied in 7e841d5.
- **Follow-up round, applied 2026-10-02 in `7e841d5`** (A-56, A-58):
  - `ccv_ooe_fet_ckpt_free` is the 48th channel. That makes 110 channel instances, 347 slots, and 274 fixed-latency slots once the redirect is counted.
  - Its width uses the repository's name for the tier-1 count, `CCV_TIER1_WARPS * CCV_P_BR_CKPTS`; there is no `CCV_P_TIER1`.
  - The schema gains a `latency_match` key, set on the free channel and naming the redirect. It requires both channels to be fixed-latency, and `tools/ccv_links.py` refuses unequal link totals.
  - The redirect therefore became fixed-latency too. That is a tightening, for confirmation (A-60).
- **Held from the same round, now resolved and applied in 0cf039a** (accepted by Daniel 2026-10-02): `CCV_LAT_L1_WAKE` and `CCV_LAT_L1_CMPL` count from MIU's real start, the later of the memop and RCU's address (A-61), and the dependency matrix gains an early and a late column per producer so bypass eligibility is decided per pair (A-62). `CCV_LAT_LANE_BYP` itself is applied as A-59 defines it.
- **Applied 2026-10-03 in `0cf039a`** (A-61, A-62, A-63):
  - `CCV_LAT_L1_WAKE` and `CCV_LAT_L1_CMPL` are generated, with `max` in the parameter grammar.
  - `CCV_LAT_RCU_ADDR` sits over `CCV_LAT_RCU_ADDR_BASE` = 2. The value is accepted as the starting point (Daniel, 2026-10-03) and stays tunable for the RCU session.
  - Every link in those formulas is counted as a whole crossing, `CCV_LAT_HOP` + its stages (A-63).
  - The two-column matrix (A-62) is internal to OOE, so nothing in the schema changes, and V-48 is owed by OOE's RTL.
- **Not yet exercised by the S1 stubs.** The lane returns `merge_data` for an inactive lane and checks it against the oracle, but no S1 kernel has a masked GPR writer, so that path is built and unreached. `CCV_OP_PRF_COPY` is not modelled: the OOE stub fails loudly on a masked load rather than run it wrong. Predicate merge by read-modify-write is reached. A kernel with masked loads and masked GPR writes is S2 work (Q-53).
- **`EV_RETIRE`** is reclassified `arbitration_sensitive` in `schema/events.json`, closing repo Q-41 as the session decided; the per-warp retirement sequence is still compared against ccv-sim.
- **Per-block specs** (FET, DEC, OOE, RCU, LANE, MIU and RAU tabs) now match the applied schema. On their Arch opens tab, A-6 is closed and A-21 settled at 48.

## The change set

Seven channels change and two are new: the RAT map and the checkpoint-free bitmap (A-56). Six change width (table below). `ccv_ooe_miu_memop` stays at 91 bits but gains the bulk-discard code. `ccv_miu_rcu_data` is **unchanged**: earlier drafts widened it, but merge moved to a fourth source operand and MIU never carries merge fields.

| Channel | Before | After |
| --- | --- | --- |
| `ccv_ooe_fet_redirect` | 201 | 107 |
| `ccv_fet_dec_instr` | 122 | 125 (+3 per slot) |
| `ccv_dec_ooe_uop` | 139 | 142 |
| `ccv_ooe_rcu_issue` | 134 | 149 |
| `ccv_rcu_lane_ops` | 111 | 143 |
| `ccv_rau_ooe_alloc` | 59 | 43 |
| `ccv_ooe_rcu_map` | — | 158, new |

**Decisions reached through the A-series review rounds, now folded in here.** The Review tab holds the reasoning and the superseded alternatives; this tab is what to implement from, and the two agree.

- Merge is a **fourth source operand**, read at issue and carried to the lane, not copy-on-allocate (A-33). The lane merges per lane, so `ccv_rcu_lane_ops` gains a separate `merge_data` field (A-51). Predicates merge in RCU by read-modify-write at write-back (A-43).
- GPR file ports are **16 reads and 8 writes**: 4 lane results and 4 load returns, and a masked load's copy op uses a lane write slot (A-33). The predicate file has its own ports: **4 reads at issue** (one guard per issued op), **up to 8 read-modify-write reads at write-back** (4 lane, 4 load; the A-43 merge) and **up to 8 writes** (A-55).
- Wakeup is a **45 x 45 dependency matrix**. Each entry tracks **up to six producers**: three GPR sources, the old GPR destination, the guard predicate, and the old predicate destination (A-43). The old GPR destination was always among them, so GPR merge adds nothing to the wakeup path (A-37). Predicate merge adds one tracked producer per entry but no matrix width.
- Rename reservation is **per tier-1 slot, occupied or not**: 16 architectural plus a floor of 16 for GPRs, 4 plus a floor of 4 for predicates. This is what lets restore admission **never wait**, so no credit is withheld (A-34, A-39, A-49).
- A masked load keeps **one `rob_tag` and one completion**: `CCV_OP_PRF_COPY` produces no `done` (A-38).
- `checkpoint_id` and `pred_taken` ride **per fetch slot** (A-42); restore admission **never waits**, so no credit is withheld on `ccv_rau_ooe_alloc` (A-49).

Assigned encodings, valid for the first build: **bulk discard is `mem_op` 0xF** and **`CCV_OP_PRF_COPY` is opcode 0x1FF**, each at the top of its space so ISA-derived encodings can grow upward from zero without colliding with internal micro-ops. `CCV_P_W_PHYS_PRED` is **6**.

The reasoning behind each change is in *OOE microarchitecture — Stage 4 grill-me*. Bit widths below come from the current parameters; anything marked *to size* needs the schema owner to fix a width. Widths that depend on provisional parameters move with them.

## Channel changes

Seven existing channels change, six of them in width and one channel is new. Widths are bits per slot.

| Channel | Before | After | Blocks | Reason |
| --- | --- | --- | --- | --- |
| `ccv_ooe_fet_redirect` | 201: `warp_id` 5, `tier1_id` 2, `target_pc` 64, `group_masks` 128, `fetch_epoch` 2 | 107: `warp_id` 5, `tier1_id` 2, **`checkpoint_id` 2**, **`taken_mask` 32**, `target_pc` 64, `fetch_epoch` 2. `group_masks` removed | OOE, FET | FET holds branch checkpoints and restores PC-group state itself |
| `ccv_fet_dec_instr` | 122 | +3 per slot: `checkpoint_id` 2 and **`pred_taken` 1** (A-42), valid on branches | FET, DEC | Carries the checkpoint and the predicted direction from FET to DEC |
| `ccv_dec_ooe_uop` | 139 | 142: **`checkpoint_id` 2** and **`pred_taken` 1**, valid on branches | DEC, OOE | OOE compares RCU's resolved outcome against `pred_taken` to detect a mispredict, then names the checkpoint (A-42). A predicted mask replaces the bit when divergent prediction lands |
| `ccv_ooe_rcu_issue` | 134 | 149: **`phys_old_dst` 8**, **`phys_pred_old_dst` 6** and **`merge_en` 1** | OOE, RCU | The implicit old-destination source. Read at issue with the other operands and carried with them, so the bypass network supplies it like any source. The lane merges: active lanes take the ALU result, inactive lanes the carried value. Don't-care when elided (full mask, unguarded). Predicates merge in RCU instead: at write-back RCU reads `phys_pred_old_dst` and read-modify-writes the 32-bit predicate row (A-43). The same channel carries a copy-only op for masked loads, covering a predicate destination too (masked `cas`) |
| `ccv_ooe_miu_memop` | 91 | 91, width unchanged. `mem_op` 0xF is bulk discard, carrying the branch in rob\_tag and the warp's ROB tail in discard\_tail, a named overlay on displacement\[4:0\] valid only when mem\_op is 0xF (A-41) | OOE, MIU | Bulk discard replaces per-store discards on squash. `rob_tag` carries no age, so the message names a circular range (branch, tail\] rather than "younger than" (A-41). No merge fields: masked loads are merged by a copy-only op to RCU (A-33) |
| `ccv_miu_rcu_data` | as today | No change. The merge fields added earlier were removed by A-33 | MIU, RCU | Masked loads merge through a copy-only op on `ccv_ooe_rcu_issue`, which keeps MIU out of merging entirely. Kept in the table for traceability |
| `ccv_rau_ooe_alloc` | 59 | 43: PRF partition fields removed (`CCV_L_W_PRF_BASE` + `CCV_L_W_PRF_SIZE`, 16) | RAU, OOE | RAU allocates no physical registers. Identity fields stay, since the identity shadow stays in OOE (A-25) |
| **New:** OOE to RCU RAT map | — | 158, rate 1: `warp_id` 5, `direction` 1 (demote read / restore write), `gpr_map` 16 × 8 = 128, `pred_map` 4 × 6 = 24 | OOE, RCU | Physical locations exist only in OOE's RAT; RCU reads or writes the PRF for migration |
| `ccv_rcu_lane_ops` | 111 | **143**: a separate **`merge_data`** field of `CCV_W_LANE_DATA` carrying the merge value (A-51), not a fourth entry in `operand`. Don't-care when `merge_en` is 0 | RCU, LANE | The merge value must reach the lane so it can bypass at any stage. Holding it in RCU's pipeline instead would need 4 in flight x 7 stages x 1024 bits; spreading it across the lanes is the same bits in a better shape |
| **New: **`ccv_ooe_fet_ckpt_free` | — | 16, rate 1, fixed-latency: free\_mask = CCV\_TIER1\_WARPS × CCV\_P\_BR\_CKPTS bits, one per tier-1 slot per checkpoint, set for checkpoints freed by a correct resolution that cycle | OOE, FET | A correctly predicted branch otherwise never frees its checkpoint in FET (A-56). Branches resolve out of order, so FET cannot infer frees from a count |

**Wire counts**, by the stated convention of rate × (payload + valid + credit + stall) + wake: `ccv_ooe_fet_redirect` 205 → 111; `ccv_dec_ooe_uop` 853 → 871; `ccv_ooe_rcu_issue` 549 → 609; `ccv_rau_ooe_alloc` 63 → 47; the new RAT-map channel 162; the new checkpoint-free channel 20; `ccv_rcu_lane_ops` 457 → 585 per instance, 14,624 → 18,720 across the 32. `ccv_ooe_miu_memop` and `ccv_miu_rcu_data` keep their widths. `ccv_fet_dec_instr` grows by 3 per slot.

**Merge fields (fourth source operand, A-33).** `merge_en` = 0 when the issue mask is full and the op has no guard, since no lane keeps its old value and `phys_old_dst` is don't-care. With `merge_en` = 1, `phys_old_dst` is read at issue alongside the other sources and travels with them to the lane, which writes active lanes from the ALU result and inactive lanes from the carried value. For a masked load, OOE sends a copy-only op on `ccv_ooe_rcu_issue` when the load issues, so MIU never carries merge fields; that op's source bypasses in the same way. PRF ports are 16 reads at issue and 8 writes (4 lane, 4 load; a masked load's copy-only op uses a lane write slot). In a flop array read ports are the expensive part, which is why this beats reading the old value at write-back (20 reads). RCU holding the merge source itself was rejected because RCU has no rename table.

*Merge mechanism corrected 2026-10-02.* A-33 was first resolved as copy-on-allocate, decided on port counts alone. That misses bypassing: a PRF-to-PRF copy performed at issue cannot take its source from the bypass network, so a merging instruction would stall for its producer's full latency rather than bypassing — a penalty paid on every predicated write whose destination was recently written. Reading `phys_old_dst` with the other sources and carrying it up the pipeline makes merge an ordinary operand in every respect: wakeup, bypass, and scheduling. Reads stay at 16 and writes drop to 8, since the copies are gone, so the argument that selected copy-on-allocate over read-at-write-back still holds. It also settles A-37: `phys_old_dst` was always an RS source. OOE wakeup is a dependency matrix with no tag compares, and each entry tracks up to 6 producers (3 GPR sources, old destination, guard predicate, and since A-43 the old predicate destination), so the matrix width is unchanged.

**RAT-map channel.** On demotion, RCU reads the named rows out to PCA; on restore, it writes PCA's rows into them. It replaces RAU's `prf_base + arch` addressing entirely.

**Name and form of the new channel.** A separate rate-1 channel is recommended over a mode on `ccv_ooe_rcu_issue`, because the issue channel is rate 4 and is the binding width of the machine. The name (`ccv_ooe_rcu_map`). Its three channel attributes: acceptance atomic, since the map is one unit of 16 GPR entries plus 4 predicate entries and partial acceptance has no meaning — declaring it atomic also lets the RTL use a single counter; ordering ordered, because a demote read and a restore write for the same warp slot must not reorder even at rate 1; binding free, which carries no information on a single-slot channel but is required.

**Bulk discard encoding.** `mem_op` 0xF. `rob_tag` names the mispredicted branch's ROB entry, and `discard_tail` names the warp's ROB tail. `discard_tail` is a named overlay on `displacement[4:0]`, valid only when `mem_op` is 0xF. MIU discards every store of this `warp_id` whose ROB index lies in the circular range (branch, tail\] (A-41).

- **Tail:** the youngest allocated entry, inclusive. So tail = branch means nothing is younger and the range is empty, and a full ROB is still unambiguous.
- **No completion:** a bulk discard is a command, not a memop. It produces no `ccv_miu_ooe_cmpl`, and the outstanding-tag checker does not count it, because its `rob_tag` belongs to a branch whose completion comes from RCU (A-53).

No bits are added.

### Round of 2026-10-03: A-64 to A-66, applied in 1077054

These change rows above; the table gives the delta from the current state. Widths assume today's values and move with them.

*As applied* (custom-cuda-core `1077054`). The widths match the table: `ccv_rau_ooe_alloc` is 46 bits (50 wires) and `ccv_dec_ooe_uop` 155 (949 wires). Two specifics:

- The restore path to FET is `ccv_rau_fet_mig`, which gains `tier1_id` (9 to 11 bits); `ccv_rau_fet_launch` goes from 184 to 186.
- The zero registers are generated parameters, `CCV_P_PHYS_ZERO` = 255 and `CCV_P_PRED_ZERO` = 63. They are derived as the all-ones index, and required outside the pool (A-67).

Who computes the memop's `mem_op`, `space` and `ordering` is A-68, open.

| Channel | Change | Width | Blocks | Reason |
| --- | --- | --- | --- | --- |
| `ccv_rau_ooe_alloc` | `activate_or_free` (1) becomes a 2-bit **`op`**: free, launch, restore-allocate, restore-activate. Adds **`tier1_id`** (`CCV_W_TIER1_ID`, 2) | 43 → 46; wires 47 → 50 | RAU, OOE | Restore needs two steps or it deadlocks (A-64); OOE must know the warp's slot (A-65) |
| `ccv_rau_fet_launch` and the restore path to FET | Adds **`tier1_id`** (2) | +2 | RAU, FET | FET indexes checkpoints by slot and must agree with OOE (A-65) |
| `ccv_dec_ooe_uop` | Adds **`sched_attr`**, about 13 bits, provisional, beside `uop_class` | 142 → 155; wires 871 → 949 | DEC, OOE | OOE schedules on decoded attributes, never on `opcode` (A-66) |
| `ccv_ooe_rcu_map` | No width change. A demotion map may name the zero registers; RCU and PCA then read zeros | — | OOE, RCU, PCA | Launch maps the RAT to the zero registers (A-64) |

**Restore sequence (A-64).** RAU sends *restore-allocate*: OOE allocates 16 GPRs and 4 predicates from the slot's reservation, so it never waits, and sends `ccv_ooe_rcu_map` with `direction` 1. PCA then transfers the rows, which RCU pairs with the map (A-45). After `ccv_pca_rau_mig_done`, RAU sends *restore-activate*, and only then may the warp rename and issue. This joins repo Q-39 (no restore command to PCA), the other half of the same sequence.

**Launch and the zero registers (A-64).** Each register file has a hardwired zero register outside the pool, index 0xFF for GPRs and 63 for predicates. It always reads zero and is never written, allocated or freed. On *launch*, OOE maps all 16 architectural GPRs and 4 predicates to them; no zeroing traffic is sent. Assertions: no write ever targets a zero register, and the free lists never contain one.

**`sched_attr` (A-66).** Provisional fields: RS class (1), executes in lane or RCU (1), cross-lane (1), writes GPR (1), writes predicate (1), memory kind load/store/atomic/fence (2), branch (1), serialising none/`chwidth`/barrier/spare (2), latency class (3). DEC owns the opcode-to-attribute table, fed by the LANE and RCU op-class list from A-62. `mem_op`, `space` and `ordering` are settled in the same pass.

**Confirmed (A-63).** Each channel crossing is counted whole, `CCV_LAT_HOP` + `link_n(...)`, so `CCV_LAT_L1_WAKE` = 13 and `CCV_LAT_L1_CMPL` = 15 at no repeater stages.

**Follow-ons A-67 and A-68, resolved 2026-10-03.**

| Item | Change | Width | Status |
| --- | --- | --- | --- |
| A-67, zero-register indices | Each physical-index width is `clog2(pool + 1)`; `CCV_P_PHYS_ZERO` and `CCV_P_PRED_ZERO` are derived as the all-ones index; the generator requires each to lie outside its pool | 8 and 6 bits, 255 and 63, unchanged today | Applied in `1077054`, confirmed |
| A-68, memop fields | DEC delivers **`mem_op`**, **`space`** and **`ordering`** on `ccv_dec_ooe_uop`. OOE passes them to `ccv_ooe_miu_memop` unexamined and schedules only on `sched_attr` | `ccv_dec_ooe_uop` 155 → about 166; about 66 more wires | Applied in `95eb4f7`: 166 bits, 1,015 wires |
| `sched_attr` encoding | Confirmed as applied (MSB first: `rs_miu`, `exec_rcu`, `cross_lane`, `writes_gpr`, `writes_pred`, `mem_kind`\[2\], `branch`, `serial`\[2\], `lat_class`\[3\]). `mem_kind` is don't-care unless `rs_miu` is set. `lat_class` takes a spare code (4 to 7) for each further fixed-latency lane unit, such as SFU, once the LANE session sets its latency, each with its own generated wake parameter | 13 | Confirmed |

**`mem_op` 0xF is reserved for OOE.** OOE generates it for bulk discard (A-41), so DEC never emits it. Asserted on DEC's output, and stated in the `mem_op` encoding.

**Coverage-plan findings A-69 to A-71, resolved 2026-10-03.**

| Item | Change | Width | Status |
| --- | --- | --- | --- |
| A-69, lane mask | FET sets the 32-bit group mask at fetch; it rides on **`ccv_fet_dec_instr`** and **`ccv_dec_ooe_uop`**. OOE uses it at rename (merge elision) and issue (`issue_mask` on both issue channels) | Per slot: +32, `ccv_dec_ooe_uop` 166 → 198. Per message, if FET and DEC confirm bundles are single-group: +32 per message | To apply; per-message variant pending FET and DEC |
| A-70, wrong-path uops | **`fetch_epoch`** rides on both channels. OOE keeps a current epoch per warp, advanced on every redirect, demotion and kill, and drops any uop that does not match; DEC may drop earlier | `CCV_P_W_FETCH_EPOCH` = `clog2(CCV_P_BR_CKPTS + 2)` = 3, up from 2: +3 per slot. The redirect's `fetch_epoch` widens to match | To apply |
| Prefetch encoding | `mem_kind` load with `writes_gpr` 0 | — | Confirmed |
| A-71, unaligned lane access | Deferred to the ISA track. OOE needs no change either way | — | ISA track |

**Why 3 epoch bits.** Up to 4 unresolved branches per warp resolve out of order, so up to 4 redirects can land within one FET-to-OOE flight, and demotion or kill adds one more. Five changes in flight need 3 bits; at 2, a uop four epochs stale aliases the current epoch and executes as correct-path. An elaboration check ties the width to the checkpoint count.

**Findings A-72 to A-74, resolved 2026-10-04.**

| Item | Change | Width | Status |
| --- | --- | --- | --- |
| A-72, mask variant | Dropped. Masks stay per slot; FET and DEC are not asked to confirm single-group bundles | — | Closed |
| A-74, epoch ownership | OOE owns every warp's epoch and tells FET on `ccv_ooe_fet_redirect`. A new **`epoch_only`** bit marks a demotion or kill notice, for which `checkpoint_id`, `taken_mask` and `target_pc` are don't-care. Both sides keep the epoch per `warp_id`, never reset at launch. FET advances nothing on `ccv_rau_fet_mig` | `ccv_ooe_fet_redirect` +1 | To apply |
| A-74, kill ordering | **OOE acks a kill only once its epoch notice has landed in FET** (send cycle + the channel's fixed latency), so a relaunch always follows the notice | — | To apply |
| A-73, zero-register reads | RCU decodes `CCV_P_PHYS_ZERO` and `CCV_P_PRED_ZERO` and drives a constant; no PRF port | — | Applied in the issue-channel doc |
| A-73, matrix | Internal to OOE, no interface change: two bits per cell (dependency and late) instead of two columns, keeping the ready AND at 45 inputs | — | OOE internal |

## Parameter and encoding changes

| Parameter | Before | After | Tier |
| --- | --- | --- | --- |
| `CCV_L_W_PRF_BASE`, `CCV_L_W_PRF_SIZE` | 8 each, preliminary | **Removed**; no PRF partitions exist | — |
| `CCV_P_PRED_REGS` | 16 | **48** (A-21) | provisional |
| `CCV_P_W_PHYS_PRED` | 8 in the parameter package; the OOE tab already shows 6 | **6**, assigned; update the package | provisional |
| `CCV_P_ROB_DEPTH` | 32 | 32, confirmed for first build | provisional |
| `CCV_P_PHYS_REGS` | 192 | 192, now one global pool | provisional |
| Branch checkpoints per warp | — | **new**: 4, with a 2-bit `checkpoint_id` width | provisional |
| RS entries | unsized | **new**: 30 RCU class, 15 MIU class | provisional |
| Decode queue depth | unsized | **new**: 12 | provisional |
| Rename floor / ceiling | — | **new**: 16 / 64 per warp, floor = half the fair share of the 128 rename registers; invariant ceiling + 3 × floor ≤ 128, 16 spare, asserted at elaboration (A-34, A-40). Architectural registers and floor are reserved per tier-1 slot, occupied or not | provisional |
| Execution latencies | placeholder | **new, generated**: base pipeline + N\_out + N\_back over the outbound and return links (A-48) from `params/links.json`. Bases: RCU-only 3, lane 7 with a 4-cycle bypass, L1 hit 7 | settled once derived; bases are assumptions |
| `CCV_L_W_MEM_OP` | 4 bits, preliminary | gains a bulk-discard code, assigned **0xF** | preliminary |
| Stream tags | preliminary structure | **Removed** | — |
| Predicate rename floor / ceiling | none | **new**: 4 / 20 per warp, floor reserved per tier-1 slot whether occupied or not; ceiling + 3 × floor ≤ 32, exact fit, asserted at elaboration (A-39, A-40) | provisional |
| `CCV_L_W_PRED_STATE` | 1024, preliminary | 128, derived as 2\*\*CCV\_W\_ARCH\_PRED × CCV\_W\_LANE\_MASK; no reconvergence stack since FET owns divergence (A-50) | settled |
| `CCV_LAT_L1_WAKE, CCV_LAT_L1_CMPL` | — | **new, generated**. start = max(memop link, issue link + CCV\_LAT\_RCU\_ADDR + ccv\_rcu\_miu\_addr link), MIU's start counted from OOE's issue. WAKE = start + CCV\_LAT\_L1\_HIT + ccv\_miu\_rcu\_data link − issue link: when hit data is readable by a dependant. CMPL = start + CCV\_LAT\_L1\_HIT + ccv\_miu\_ooe\_cmpl link: when OOE learns hit or miss, which sets the cancel shadow. CCV\_LAT\_L1\_HIT is measured from the cycle MIU holds both the memop and its address. Generated in 0cf039a: 13 and 15 at no repeater stages, with max in the grammar. Each link is a whole crossing, CCV\_LAT\_HOP (2) + its repeater stages, because a max cannot fold the fixed crossing into a base (A-57, A-61, A-63) | settled once derived |
| `CCV_LAT_LANE_BYP` | 4, set directly, no reference point | 4, lane-local: base only, no link terms, from issue to dependent issue. Eligibility is per producer–consumer pair: only a lane-executing consumer reading the value as a lane operand takes it. Dependants that execute in RCU, send the value to MIU as an address or store data, or use a lane-produced predicate as guard or pred\_data use CCV\_LAT\_LANE, as do dependants of cross-lane ops (A-59, A-62) | base is an assumption |
| `CCV_LAT_RCU_ADDR` | — | **new**: RCU's time from accepting a memop's issue to its address leaving on ccv\_rcu\_miu\_addr, over a tunable CCV\_LAT\_RCU\_ADDR\_BASE (A-61) | base is an assumption, RCU session |

Names as applied: `CCV_P_W_CKPT_ID` (2, provisional because it derives from `CCV_P_BR_CKPTS`), `CCV_P_BR_CKPTS`, `CCV_P_RS_RCU`, `CCV_P_RS_MIU`, `CCV_P_DECQ`, `CCV_P_REN_FLOOR`, `CCV_P_REN_CEIL`, `CCV_P_REN_SLACK`, `CCV_P_PRED_REN_FLOOR`, `CCV_P_PRED_REN_CEIL`, `CCV_P_PRED_REN_SLACK`, `CCV_P_W_ROB_IDX`, and the generated latencies `CCV_LAT_RCU`, `CCV_LAT_LANE`, `CCV_LAT_LANE_BYP` and `CCV_LAT_L1_HIT`, each over a `_BASE` assumption.

## Ownership and scope changes

| Responsibility | Was | Now | Tabs to update |
| --- | --- | --- | --- |
| Physical register allocation | RAU, as PRF partitions via the buddy/slab allocator | OOE's global free lists; RAU allocates nothing | RAU, OOE |
| Locating a warp's architectural registers for migration | Implicit in the partition base | OOE sends the RAT map to RCU; PCA reads and writes rows through it | OOE, RCU, PCA, RAU |
| Branch prediction | Unstated | FET, uniform-only first | FET, OOE |
| Branch recovery state (PC groups and masks per unresolved branch) | Resent by OOE on every redirect | FET, as 4 checkpoints per warp | FET, OOE |
| Identity shadow (`warp_base`, `%ctaid`, 37 bits per warp) | OOE | **Stays in OOE; substituted into the imm slot for srd ops (A-25)** | OOE, RCU, RAU |
| Non-contiguous squash (stream tags) | OOE | Removed; squash is contiguous | OOE |
| All scheduling, including register ports and write-back timing | Partly implied in RCU by Q-51 | OOE alone, under a fixed-latency contract | OOE, RCU, LANE |

## Behavioural contracts

These change what a channel promises without changing its bits. Each should become a stated rule on the channel and, where possible, a checker.

| Channel or path | Contract | Checkable as |
| --- | --- | --- |
| `ccv_ooe_rcu_issue`, lane pipelines | Fixed latency is a contract: once RCU accepts an issue, the result lands exactly at its configured latency. RCU never slips | Arrival-cycle checker per completion channel |
| `ccv_ooe_rcu_issue` | No register-file port grant; the PRF has ports for peak issue. Closes Q-51 | — |
| `ccv_miu_ooe_cmpl` | The miss indication is a cancel: dependants woken for an L1 hit are cancelled transitively | Cancel event |
| `ccv_ooe_miu_memop` | Address sources are confirmed before issue, so MIU never receives a memop that can later be cancelled | OOE assertion |
| `ccv_ooe_miu_memop` | Bulk discard and new memops for the same warp are never sent in the same cycle | OOE assertion |
| `ccv_miu_ooe_cmpl`, `ccv_miu_rcu_data` | MIU completes every memop it accepts, even after OOE squashes it. OOE holds the squashed entry's registers and ROB slot until that completion, then drops it | `quiesced_at_end`; deferred-free event |
| `ccv_ooe_rau_drained` | Sent only after every outstanding memop of the warp completes and the RAT map has gone to RCU | OOE assertion |
| Kill ack | OOE acks only once no memop for the killed warps is outstanding | Existing kill ack checker |
| `ccv_ooe_rau_status.fault_taken` | OOE stops retiring the warp and does not squash; RAU's kill does all cleanup | — |
| `ccv_ooe_fet_redirect` | Rate 1 is deliberate: OOE redirects only on a mispredict and serialises them (A-6) | Redirect-busy event |
| `EV_RETIRE` | Arbitration-sensitive under Q-1. The per-warp retirement sequence is correlated against ccv-sim separately (Q-41) | Correlation check |
| `ccv_ooe_miu_memop` | On a bulk discard, `rob_tag` names the branch's ROB index, and `discard_tail` (`displacement[4:0]`, declared as a named overlay in the schema) carries the warp's ROB tail: the youngest allocated entry, inclusive. MIU discards stores in the circular range (branch, tail\]. Every other field is reserved and zero, as in A-10 (A-41). The discard itself is not a memop and produces no completion (A-53). | Channel checker, reserved-zero rule |
| `ccv_miu_ooe_cmpl` | A rob\_tag whose squashed entry has a memop outstanding is not reallocated until MIU completes it | New outstanding-tag checker: no allocation of a tag with a memop in flight |
| `ccv_ooe_rcu_issue` | With `merge_en` = 1, `phys_old_dst` is read at issue with the other sources and carried to the lane, which writes active lanes from the ALU result and inactive lanes from the carried value. A masked load issues a copy-only op here when it issues to MIU (A-33). The copy op writes only the load's inactive lanes and the load data only its active lanes, so the two can land in either order; the load's dependants wake on the later of the two | A-35 every-lane-written assertion; masked-load copy event |
| `ccv_rcu_ooe_done` | A CCV\_OP\_PRF\_COPY op produces no done. Its masked load keeps one rob\_tag, so every tag still sees exactly one completion, the load's (A-38) | Outstanding-tag checker unchanged; arrival checker covers the copy; assertion of exactly one copy op per masked load, matched on rob\_tag |
| `ccv_miu_ooe_cmpl` | Every accepted memop gets exactly one completion, including stores later bulk-discarded (A-41); the bulk-discard message itself is not a memop and gets none (A-53). An L1 hit completes at exactly the contracted cycle, and its data arrives on ccv\_miu\_rcu\_data at the contracted cycle too, since dependants woken at hit latency read it; no completion at that cycle is the miss indication. Past L1 nothing is contracted: after a miss, and for scratchpad loads and atomics, dependants wake on the actual completion (A-46) | Outstanding-tag checker; L1-hit arrival checker |
| Fixed-latency path | ccv\_ooe\_rcu\_issue, ccv\_rcu\_lane\_ops, ccv\_lane\_rcu\_res, ccv\_rcu\_ooe\_done, ccv\_miu\_ooe\_cmpl and ccv\_miu\_rcu\_data carry a declared fixed-latency attribute, as do ccv\_ooe\_fet\_redirect and ccv\_ooe\_fet\_ckpt\_free, the latency-matched pair (A-58, A-60): the receiver never stalls and returns credit every cycle (A-47) | New attribute checker on each channel |
| `ccv_rcu_lane_ops / PRF write` | With merge\_en set, a lane outputs merge\_data for its inactive lanes; pred\_bit clear no longer means "does nothing". RCU writes the PRF through per-lane write enables; for a copy op it enables only the inactive lanes, which the load does not own (A-44) | A-35 every-lane-written assertion |
| `ccv_rau_rcu_mig + ccv_ooe_rcu_map` | RCU pairs the two by warp and direction and proceeds once both have arrived, in either order. At most one migration per warp is in flight (A-45) | Pairing checker: warp and direction agree |
| `ccv_ooe_fet_ckpt_free` | Sent every cycle; a set bit frees that checkpoint in FET. A checkpoint is freed exactly once: by this channel on a correct resolution, or by FET itself when a redirect restores an older checkpoint or a demotion or kill resets the warp. Fixed-latency attribute; FET never stalls it (A-56). No stale frees (A-58): OOE never sends a free for a checkpoint that the same cycle's redirect squashes, and drops resolutions of squashed branches. This channel and `ccv_ooe_fet_redirect` are a latency-matched pair with equal link stages, so arrival order equals send order. FET applies a redirect before frees in the same cycle. Checked by an elaboration check on the pair, plus an assertion that every free bit names a checkpoint live in FET on arrival | Attribute checker; V-08 live-set equality, now P1 |

**Context-isolation assertions (A-35).** Context isolation now rests on the merge path rather than a bulk clear, so a merge bug would be a cross-context leak. Two RCU assertions guard it: every lane of a newly allocated physical register is written before any read of it, and the 16 GPRs and 4 predicates allocated at warp activation read as zero.

**Checker count.** The checker bank gains one arrival checker per fixed-latency completion channel and one outstanding-tag checker on `ccv_miu_ooe_cmpl`. The new RAT-map channel adds its credit and wake checkers as usual.

*As built (`3543276`):* only the attribute checker exists so far. `fixed_latency_no_stall` and `fixed_latency_prompt` run on all 272 fixed-latency slots, and `--break fixed-all` fires on every one. The arrival-cycle checkers, the outstanding-tag checker, RCU's two A-35 assertions, the pairing checker and the OOE assertions in the table above each need the block's internals, so they are built with that block (repo Q-53). The RAT-map channel's credit and wake checkers are in the bank.

**Unchanged on purpose.**

- `ccv_ooe_rcu_issue` gets no register-file port grant (Q-51 closed): the PRF has enough ports for peak issue.
- `ccv_rcu_ooe_done` gets no late or cancel bit: the latency contract makes it unnecessary.
- `ccv_ooe_rau_drained` keeps its 70 bits: the resume PC still goes to RAU, and the map goes to RCU on the new channel.

## Items for other owners

| Owner | Item |
| --- | --- |
| Arch agent | Apply every change above to the high-level spec and the schema, and register cross-block items in Arch opens |
| Arch agent | Identity shadow stays in OOE (A-25, resolved) |
| Arch agent | Name and form of the OOE-to-RCU RAT map channel |
| Arch agent | Close A-6, A-21, Q-35, Q-41 and Q-51 with the resolutions recorded here |
| RAU session | Remove PRF allocation, the buddy/slab allocator and the partition fields from `ccv_rau_ooe_alloc`; set demotion threshold CSRs |
| RCU session | Fourth-operand merge: `phys_old_dst` read at issue and carried to the lane, which merges per lane. Copy-only ops for masked loads, covering a predicate destination too. GPR file ports of 16 reads and 8 writes. Predicate file ports of 4 issue reads, up to 8 write-back read-modify-write reads and up to 8 writes (A-55). Predicate merge by read-modify-write at write-back (A-43). Per-lane PRF write enables, where the copy-only op writes only the load's inactive lanes (A-44). The two A-35 assertions. Receive the RAT map for migration, paired with `ccv_rau_rcu_mig` (A-45). |
| FET session | Branch prediction (uniform-only first); 4 checkpoints per warp; restore from `checkpoint_id` + `taken_mask`; free checkpoints on `ccv_ooe_fet_ckpt_free`, and drop younger ones itself on a redirect (A-56); reconvergence by min-PC merge (A-32) |
| DEC session | Carry `checkpoint_id` and `pred_taken` from FET to OOE, per slot (A-42) |
| MIU session | Bulk-discard decode: the range (branch, tail\], with no completion for the discard itself (A-41, A-53). Complete every accepted memop. Confirm L1 hit latency, and land hit data on `ccv_miu_rcu_data` at the contracted cycle (A-47). **No early hit/miss indication** (A-54). No completion at the hit cycle is the miss signal (A-46), and a second message per tag would break one completion per tag (A-38). Shrinking the cancel shadow later would need a separate, non-completion signal and a new open. |
| LANE session | Confirm 7-cycle latency and 4-cycle bypass as a contract. Bypass is lane-local: a bypass mux in each lane, and the list of op classes that cannot bypass locally (shuffles, reductions, other cross-lane ops) (A-59) |
| PCA session | Migrate rows at the physical locations named by the RAT map |
| Arch agent | Resolved: **admission never waits** (A-49). Each tier-1 slot, occupied or not, keeps 16 architectural GPRs plus a floor of 16, and 4 architectural predicates plus a floor of 4, reserved, so a restore always finds its registers. Credit withholding, first chosen here, is dropped: it could never engage, and a withheld credit would trip the credit checker's `response_within_n`. |
| Arch agent, FET session | Resolved: `checkpoint_id` and `pred_taken` ride per fetch slot, +3 per slot (A-42), valid on branches and don't-care otherwise. Identifying one slot instead would cost a 3-bit slot index plus the 3 bits, against 24 bits for per-slot. It would also couple DEC to FET's slot packing, for almost no saving on a 1,000-bit channel. |
| Arch agent | Check the three derived changes first: the merge fields, ccv\_rau\_ooe\_alloc at 43 bits (assumes the partition was exactly prf\_base + prf\_size, and identity still rides it), and the per-slot checkpoint\_id |
| Arch agent | Apply the assigned encodings: bulk discard is mem\_op 0xF, and CCV\_OP\_PRF\_COPY is opcode 0x1FF in the ccv\_ooe\_rcu\_issue opcode space, both at the top of their spaces so ISA-derived codes grow upward from zero — a distinct opcode rather than merge\_en with a null operation, because it is checkable: an assertion can require exactly one copy op per masked load, matched on rob\_tag; and remove CCV\_L\_W\_PRF\_BASE / SIZE from ccv\_prelim\_pkg |
