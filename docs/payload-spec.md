<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->

# Payload specification — all 55 channels

Every payload field has a width, so **every one of the 55
channels generates a packed struct** and the skeleton can be
wired end to end. The cost is that some widths are guesses, and
the job of this document is to make sure a guess can never be
mistaken for a decision.

## Three tiers of trust

Every width resolves through one of three packages, and the
package name is visible at the use site. That is the whole
mechanism: a reader of any struct definition can tell how much
trust the number deserves without looking anything up.

| Package | Meaning | Expected to move | Mark |
|---|---|---|---|
| `ccv_params_pkg` | follows from a settled decision, traceable to the ISA or a partitioning choice | no | |
| `ccv_prov_pkg` | a sizing placeholder awaiting a per-block session | the number | ⚠️ |
| `ccv_prelim_pkg` | no decided encoding at all; the width is a first guess | possibly the **field itself** | ⛔ |

`ccv_prelim_pkg` exists so skeleton coding is unblocked without
pretending the encodings are known. A preliminary width says the
field is real and roughly this big; it does **not** say the
encoding, the field count or the semantics are settled.

**Churn** rates the field, not the number. *High* means a
per-block session is likely to change the field's shape, so code
that pattern-matches on its contents will need rewriting; *low*
means only the number moves. `docs/trust-report.md` is the
build artifact listing everything that references either of the
bottom two tiers.

## Summary

Each channel is classified by the **weakest** width it carries,
since a struct is only as settled as its least-decided field.

| Weakest width on the channel | Channels | Fields |
|---|---|---|
| All decided | 14 | 36 |
| ⚠️ Some provisional | 26 | 134 |
| ⛔ Some preliminary | 15 | 139 |
| **Total** | **55** | **309** |

## What still has to be decided

Grouped by who decides. Highest churn first within each group,
because those are the ones where a skeleton that reads the field
— rather than merely carrying it — will need rework.

### CRU session -- the CSR fabric has no topology yet

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_CSR_ADDR` | 16 | med | CSR address. A first guess, made only so the common CSR port can be declared: the schema gave csr_req as 'address, write data, write enable' with no widths, and there is no CSR map yet. |

### DEC block session -- is class derivable from opcode?

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_CLASS` | 3 | low | Eight uop classes: integer, float, SFU and convert, memory, control, collective, predicate, spare. DEC decides whether class is derivable from opcode at all. |

### DEC per-block session, with the LANE and RCU op-class list (A-62, A-66)

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_P_W_SCHED_ATTR` | 21 | med | Width of sched_attr on ccv_dec_ooe_uop: the scheduling attributes DEC decodes so OOE never decodes opcode (A-66). Layout, MSB first: commit_width (1: a chwidth.multi sibling that commits its register's width at retire without serial's hold, which sits on the last sibling only; AR-24 (c), OA's rev 222), ret (1: the branch is a ret, so OOE takes its target from ccv_rcu_ooe_done.aux and sets the redirect's stay; AR-24 (b), OA's rev 223), pair_second and pair_first (1 each: a pair's two decode slots under one ROB entry; TI-39, OA's rev 189. A uop that needs k rows of any RS class, or k names, occupies k slots, at most one row per class and one name a slot: the CAS pair, and every single-slot RMW atomic, which DEC emits as a pair (OI-80 (d), DA tab rev 94)), bypass_group (3: the codes of CCV_P_BYP_GROUPS; 0, don't-care, for an op that writes no result and reads no GPR, such as a branch or exit; OI-16, added 2026-10-08), rs_miu (1: the MIU reservation station), exec_rcu (1: RCU executes it, not a lane), cross_lane (1), writes_gpr (1), writes_pred (1), mem_kind (2: load, store, atomic, fence; meaningful with rs_miu), branch (1), serial (3: 0 none, 1 chwidth, 2 barrier wait, 3 exit, 4 barrier arrive, 5-7 spare; TI-41, OA's rev 198; exit, TI-1: OOE holds it until every older uop of its warp completes and retires it as the warp's last), lat_class (3: 0 RCU, 1 lane, 2 L1-contracted load, 3 on completion, 4 SFU at CCV_LAT_SFU, 5 warp-collective at CCV_LAT_COLLECTIVE, 6-7 spare). mem_kind is don't-care unless rs_miu is set. SFU takes lat_class 4 and the warp-collective ops 5, with CCV_LAT_SFU and CCV_LAT_COLLECTIVE (Daniel's responses OA-4); a further fixed-latency unit takes 6 or 7, with its own latency parameter. Field set the OOE session's, bit order and codes the schema owner's; confirmed 2026-10-03. |

### EXB session -- flattened bundle or separate TL channels

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_TL_IN` | 1176 | **HIGH** | TL-C inbound, B + D plus a valid bit per TL channel: B 641 (as A), D 533 (opcode 3, param 2, size 4, source 6, sink 4, denied 1, data 512, corrupt 1), valids 2. The earlier single 1760 reproduces exactly as A + C + D + E + 5 valids -- it never included B, the probe. |
| `CCV_L_W_TL_OUT` | 1225 | **HIGH** | TL-C outbound, A + C + E plus a valid bit per TL channel, at 512-bit beat, 48-bit address, 6-bit source, 4-bit sink: A 641 (opcode 3, param 3, size 4, source 6, address 48, mask 64, data 512, corrupt 1), C 577 (A without mask), E 4 (sink), valids 3. |

### ISA opcode census, then DEC/OOE/RCU agree the hops

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_OPCODE` | 9 | **HIGH** | One encoding across all three hops, owned by the schema (Q-34): a block may narrow it locally only as a strict projection, never a re-encoding. Narrowing at RCU->LANE is likely, but the ISA opcode census sets it. Anything decoding this field will be rewritten. |

### LANE per-block session (register OA-4)

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_P_BYP_GROUPS` | 8 | med | Bypass groups: the codes of sched_attr's 3-bit bypass_group (0 integer, 1 floating point, 2 address calculation, 3 SFU, 4 warp-collective, 5 predicate, 6-7 spare), which index the bypass table both ways, byp[producer group][consumer group] (OI-16). A memop consumes as address calculation. A cell is a penalty in cycles after the producer's fastest bypass point, capped at the PRF read: in-unit CCV_LAT_BYP_PEN_SAME, integer and FP to each other CCV_LAT_BYP_PEN_INT_FP, integer or FP and SFU to each other CCV_LAT_BYP_PEN_SFU. Address-calculation, warp-collective and predicate consumers never bypass, nor does a warp-collective or predicate producer (A-59, A-62, V-48). |
| `CCV_P_LAT_CLASSES` | 8 | med | Latency classes the scheduler distinguishes: the codes of sched_attr's 3-bit lat_class (0 RCU, 1 lane, 2 L1 load, 3 on completion, 4 SFU, 5 warp-collective, 6-7 spare). A class sets a producer's full latency; which consumers it may wake early is its bypass_group's (OI-16, Daniel's responses OA-4). |
| `CCV_P_W_BYP_GROUP` | 3 | med | bypass_group's width, on sched_attr and on ccv_ooe_rcu_issue. |

### MIU block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_MEM_OP` | 4 | med | Memory operation, enumerated (AR's and OA's responses IS-11 and AR-21): 0 load, 1 store, 2 atomic-read (an atomic's A1: read the old values and hold the lines), 3 atomic-write (its A3: write the new values and release), 4 predicate load (ld.pred), 5 predicate store (st.pred), 0xE fence, 0xF OOE's bulk discard; 6-0xD spare. 4 and 5 are DEC's, one uop per predicate of the mask (AR's response TI-36): to OOE a load and a store; to MIU one word at lane 0's address. DEC emits load, store, the predicate transfers and fence from its table; 2, 3 and 0xF are OOE's alone (V-72, V-52). An atomic's operation is not here: it travels as the A2 lane op's opcode. The ISA has no prefetch, so there is no prefetch code (OA's response IS-11, which removes A-68's prefetch row). ordering is non-zero only with 0xE. Decoded by DEC and passed through OOE (A-68). Code 0xF is reserved for OOE's bulk discard (A-41): DEC never emits it. |

### MLC/EXB session, alongside CCV_L_W_COH_OP

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_OWNERSHIP` | 3 | med | TL-C permission levels plus an explicit dirty bit, kept wider than TL-C needs so a CHI bridge maps without a second translation. |
| `CCV_L_W_PROBE_TYPE` | 2 | med | Kind of inbound message on ccv_exb_mlc_rsp: 0 = a response to a request; otherwise a probe and what it asks (to-invalid, to-branch, to-trunk, after TL-C Probe param). Replaces the one-bit inbound_probe flag. |

### MLC/EXB session, once the TL-C subset is chosen

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_COH_OP` | 4 | med | Coherent line request: acquire, release, probe response, writeback, grant acknowledgement. Follows the TL-C subset chosen. |

### MMU session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_PAGE_SHIFT` | 12 | low | Page shift, used to express code bounds at page granularity. 4 KB pages assumed; the MMU session confirms. |

### MMU session, with the page-table format

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_ITLB_ENTRY` | 64 | low | ITLB entry: physical page number, permissions, ASID and valid, rounded up. |

### RAU / CRU sessions

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_GRID_SEL` | 8 | med | Grid selector on the host's kill request (ccv_cru_rau_cfg). RAU maps grid to warp mask from tables it owns. Sized for 256 grid slots; the real number is how many grids RAU tracks at once. |

### RCU/LANE session -- see the src_arch vs operand mismatch

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_OPERANDS_PER_LANE` | 3 | **HIGH** | Operands shipped to a lane per beat. Whether a lane receives one instruction's operands or several, and whether the destination is read back for accumulate, both change this. |

### RCU/LANE session, with CCV_L_OPERANDS_PER_LANE

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_PRF_LANE_READ_BITS` | 4096 | **HIGH** | PRF read bandwidth into the lanes, a budget line: four operand ports (three sources and the merge source) of 1,024 bits, one byte a section per lane, each byte from its own section bank. Sixteen survives only as a count of slice reads. |

### SPM block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_SPM_OP` | 2 | low | Scratchpad bank access: read, write, and room for a read-modify variant. |

### generated

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_OP_PRF_COPY` | 511 | low | The copy-only op's opcode on ccv_ooe_rcu_issue and ccv_rcu_lane_ops: the all-ones code, which no ISA opcode takes. A masked load issues it beside the load, with the load's rob_tag and destinations and the old destination as merge_data: a lane returns merge_data on its inactive lanes, RCU writes only those, and no done comes back -- the load keeps one completion, its own (A-38). OOE clears the load's copy-pending at issue + CCV_LAT_LANE, as for any lane op; RCU owes the PRF write within CCV_LAT_LANE of accepting it. |

## Open questions that no width can close

Each is numbered in [`open-items.md`](open-items.md), the one list of what is undecided.

### Q-18 — rcu miu width

*partitioning question that a width exposed — partitioning / floorplan*

ccv_rcu_miu_addr carries index_per_lane (1024) beside store_data (1024) at rate 4 -- roughly 8,400 wires from RCU into MIU, almost certainly the widest interface in the design. It argues for co-locating the AGUs with RCU, or moving address generation into the register read stage.

**Blocks:** Nothing today -- the skeleton does not care how wide a bus is. Settle before floorplan rather than after, since the answer may move a block boundary and block boundaries are swap boundaries.

---

## Every channel

## All widths decided

### `ccv_lane_rcu_res`

One lane's results, one message a cycle (OI-28): a 32-bit result, used whole by a full-width op and by section for narrow ones, already steered to each destination's position inside the lane; per section, sec_valid (an op's result is here), sec_pred_out (setp's compare, add.pp's predicate: one bit a lane per op, on the op's lead section). RCU knows which op held which section, the lane latency being fixed, so no tag rides here. RCU writes the PRF by slice through per-lane write enables: every lane for an ordinary op (an inactive lane's result is its merge_data), only the inactive lanes for CCV_OP_PRF_COPY (A-44).

lane → rcu · rate 1 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `result` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `sec_valid` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| `sec_pred_out` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| **total** | | **40** | |

### `ccv_ooe_rau_status`

Per-warp stall and progress reporting, feeding demotion policy -- and fault_taken, the fault path to RAU: OOE raises it at retirement with the warp_id, and RAU kills every warp of the context: with one resident context (the ASID field's contract), every valid warp context, resident and parked, with no lookup, and it stops every queued launch (DA's response IS-2, 2026-10-20: a fatal fault terminates the context, not the grid). The host's kill_grid on ccv_cru_rau_cfg stays grid-scoped: it is a request, not a fault. CRU records the fault in parallel (ccv_ooe_cru_fault) for the host, and is not on the path that stops execution. EXITED (AR's response TI-24 (2), OA's rev 149): a level, set once the warp's C_EXIT has retired and the warp holds no ROB entry, deferred-free or squashed-pending slot included, and no memop outstanding at MIU, the kill's quiesce; held until RAU frees the slot (alloc_op 0). RAU then frees the tier-1 slot, and on a CTA's last warp the CTA's scratchpad, barrier entries and CTA slot. A committed store still draining is never matched by rob_tag or warp_id again (MIU spec), so both may be reused.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `fault_taken` | `1` | 1 | literal |
| `stalled` | `1` | 1 | literal |
| `mlc_miss_seen` | `1` | 1 | literal |
| `retired_since_restore` | `CCV_W_RETIRED_CNT` | 8 | CCV_W_RETIRED_CNT (arch) |
| `exited` | `1` | 1 | literal |
| **total** | | **17** | |

### `ccv_rau_ooe_demote`

The order to squash a warp to its retirement boundary and report where to resume.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `squash_to_retirement` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_ooe_rau_drained`

Confirmation that only architectural state remains, with the resume PC. Migration may begin. OOE sends it only once the epoch notice it sent for the demotion (epoch_only on ccv_ooe_fet_redirect, A-74) has landed in FET, at its send cycle plus that channel's fixed latency, the same rule as its kill_ack. The guarantee that a restored warp is never fetched under an epoch older than OOE's (V-57) is then explicit rather than resting on the migration handshake's length. Every demote gets exactly one drained. REFUSED (OA's response TI-25 (2)): a demote that lands after the warp's exit has retired is refused, with no squash, no map and no rewind beats, and drained carries refused = 1; RAU cancels the demotion (no migration commands), and exited frees the slot as for any finishing warp. A demote that lands before the exit retires is an ordinary demotion, and the squash takes the exit with it.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `resume_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `arch_state_ready` | `1` | 1 | literal |
| `refused` | `1` | 1 | literal |
| **total** | | **71** | |

### `ccv_rau_rcu_mig`

Which warp and direction a migration moves. RCU pairs it with ccv_ooe_rcu_map by warp_id and direction and proceeds once both have arrived, in either order; at most one migration per warp is in flight (A-45).

rau → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_rcu_pca_mig`

Architectural state out to the parked array on demotion, one 1024-bit row per message. Rows 0 to 15 are the 16 GPRs; rows 16 and up carry the warp's predicate state (CCV_W_PRED_STATE bits, ceil(CCV_W_PRED_STATE / CCV_W_DATA) rows, one today). Addressed: warp_id and mig_row say where the row goes, so PCA places it from the data itself rather than inferring placement from a command it never sees (the RAU->RCU command is RCU's). Predicate state travels once per migration, not beside every GPR row (arch open A-1). The PC groups are not here: FET owns them, and they travel on ccv_fet_pca_mig.

rcu → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `mig_row` | `CCV_W_MIG_ROW` | 5 | CCV_W_MIG_ROW (arch) |
| `row_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1034** | |

### `ccv_pca_rcu_mig`

Architectural state back in on restore, one 1024-bit row per message in the same row numbering as ccv_rcu_pca_mig (0 to 15 GPRs, 16 and up predicate state), addressed by warp_id and mig_row so RCU writes it without state. RCU consumes a row only once it holds the warp's map (ccv_ooe_rcu_map, which it pairs with ccv_rau_rcu_mig in either order, A-45) and writes the row as it consumes it, so a row's credit coming back means the row is written (TI-13). The PC groups and their lane masks return to FET on ccv_pca_fet_mig.

pca → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `mig_row` | `CCV_W_MIG_ROW` | 5 | CCV_W_MIG_ROW (arch) |
| `row_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1034** | |

### `ccv_rau_fet_mig`

The migration command to FET, the same command ccv_rau_rcu_mig gives RCU: which warp, which direction. On demotion FET sends the warp's PC groups on ccv_fet_pca_mig. RAU sequences both halves of a migration, so both halves need the command. tier1_id is the warp's tier-1 slot (A-65): on a restore, the slot RAU is placing it in, which FET needs before PCA's PC groups arrive; on a demotion, the slot being vacated.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `direction` | `1` | 1 | literal |
| **total** | | **8** | |

### `ccv_pca_rau_mig_done`

A migration has landed, either way. direction 0: a demotion, PCA holds every row from RCU and the PC groups from FET for warp_id, and RAU may reallocate the warp's slot. direction 1: a restore, every row PCA sent to RCU on ccv_pca_rcu_mig has had its credit back, so RCU has written it, and PCA has sent the PC groups to FET; RAU may activate the warp. PCA sends it only once the last row's credit is back: a row sent but still in RCU's receiver, waiting for the warp's map, is not written, and a warp activated on it could read the row before it lands. Done means written (TI-13). One ack from the block that sees both halves, rather than one from each sender (arch open A-3; the restore COMMAND is Q-39).

pca → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_rau_pca_mig`

The migration command to PCA (AR's response TI-24 (1); repo Q-39), the third beside ccv_rau_rcu_mig and ccv_rau_fet_mig: which warp, which direction, and its place in the parked array. RAU allocates the place from a free list of CCV_PARKED_WARPS on a demotion and frees it once the warp is restored, so PCA stores by place and holds no table. direction 0: PCA files the rows from RCU and the PCs from FET at pca_place, and acks on ccv_pca_rau_mig_done once it holds both. direction 1: PCA sends the warp's rows on ccv_pca_rcu_mig and its PCs on ccv_pca_fet_mig, then acks direction 1 once every row's credit is back (done means written, TI-13). It replaces bank_select on the other two commands, which reached only RCU and FET, neither of which stores anything.

rau → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `pca_place` | `CCV_W_PCA_PLACE` | 5 | CCV_W_PCA_PLACE (arch) |
| **total** | | **11** | |

### `ccv_miu_rau_ready`

A demoted warp is ready to restore (AR's response TI-21, rev 107; OA's rev 160): MIU sends its warp_id when the warp's count of orphaned loads, the requests a bulk discard abandoned at DCU, returns to zero. Then every line the warp asked for has landed in DCU, so its replayed loads hit after the restore; a restore before then would replay into the same miss and hold the slot again. Only MIU sees the orphan drop, so MIU counts, one counter per warp context (CCV_WARP_CONTEXTS, each up to 2^CCV_P_W_REQ_MIU_DCU). A kill clears a warp's count with no report. RAU restores a parked warp only once it is ready. RAU already sends to MIU (ccv_rau_miu_cta), so the blocks touch.

miu → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| **total** | | **5** | |

### `ccv_syu_ooe_rel`

SYU's answer to a held wait (TI-40, DA's PF-44 variant): the converged warp's barrier has completed, and OOE lifts the rename hold behind its retired wait. One answer per held wait, after it retires; a wait FET parked (not held) is answered on ccv_syu_fet_rel instead, never here, so no answer reaches a later wait (AR's rev 164). If it lands while OOE holds nothing for the warp (a squash or a demotion took the wait), OOE drops it. It is in a demotion's drain.

syu → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| **total** | | **5** | |

### `ccv_syu_fet_rel`

SYU's answer to a retired wait FET parked (TI-40, AR's rev 161): lane_mask is the lanes released, those of the wait whose barrier has completed, or was already met when the wait retired (a guard false, its own arrival complete, the phase reached). FET clears their waiting bits in the current state and every live checkpoint of the warp's slot, so a later mispredict cannot park them again. Exactly one answer per lane of each retired wait, so no answer reaches a later wait. For a context that is not resident SYU sends ccv_syu_rau_ready instead. In a demotion's drain, so an answer in flight lands before FET migrates.

syu → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **37** | |

### `ccv_syu_rau_ready`

A parked warp's barrier answer (TI-40, AR's rev 161): SYU answers a wait of a context that is not resident by telling RAU the warp is ready, and answers a demote op at once with it when the context has no waiting lanes. RAU restores it; FET rewound its waiting lanes to their waits at the demotion, so they fetch the wait again and ask again, which is exact since a wait has no side effect.

syu → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| **total** | | **5** | |

## ⚠️ Carries a provisional width

### `ccv_fet_dec_instr`

Fetched, length-decoded, aligned instruction words, two per warp across all four tier-1 warps. Fetch faults ride here rather than a separate path. On a branch, checkpoint_id names the PC-group checkpoint FET took for it and pred_taken FET's predicted direction (uniform-only first; A-42); both are don't-care on other instructions. A predicted mask replaces pred_taken when divergent prediction lands. GROUP MASK AND EPOCH (A-69, A-70): group_mask is the lanes of the PC group the instruction was fetched for, set by FET, which owns the groups, and carried through DEC to OOE, which needs it at rename (merge elision: is the mask full?) and sends it as issue_mask. fetch_epoch is the warp's epoch when it was fetched: FET takes a new one from every redirect, and DEC and OOE drop any uop whose epoch is not the warp's current one, which is how wrong-path uops still in this channel, in DEC or in the decode queue are discarded after a redirect. FINAL EXIT (AR's and OA's responses TI-27): final_exit marks the exit whose fetch clears the warp's last live lanes. Exit is never predicated, so fetching one exits exactly its group's lanes. A squash that discards an earlier exit discards the mark with it, and the refetched final exit is marked again once FET's mask is restored. ALL_WAITING (TI-40, AR's revs 161-164): On a chwidth it is the chwidth's convergence instead (O-81; ccv_dec_ooe_uop says how OOE takes it): set when the chwidth's group is every live lane, the converged wait's test. Otherwise FET sets it on the instruction whose fetch leaves every live lane of the warp waiting at a barrier: a wait whose group is every live lane (a converged wait, which FET does not park and marks no waiting bits for; OOE holds rename behind it), or an exit by the last group not waiting. OOE starts CCV_DEMOTION_THRESHOLD_BARRIER's timer when the marked uop retires with nothing younger in its warp. DEC passes it through.

fet → dec · rate 8 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `group_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `fetch_epoch` | `CCV_P_W_FETCH_EPOCH` | 3 ⚠️ | CCV_P_W_FETCH_EPOCH (provisional) |
| `instr` | `CCV_W_INSTR` | 48 | CCV_W_INSTR (isa) |
| `length` | `CCV_W_ILEN` | 2 | CCV_W_ILEN (isa) |
| `checkpoint_id` | `CCV_P_W_CKPT_ID` | 2 ⚠️ | CCV_P_W_CKPT_ID (provisional) |
| `pred_taken` | `1` | 1 | literal |
| `fetch_fault` | `1` | 1 | literal |
| `final_exit` | `1` | 1 | literal |
| `all_waiting` | `1` | 1 | literal |
| **total** | | **162** | ⚠️ 5 provisional |

### `ccv_ooe_fet_decq_credit`

Decode-queue credits back to FET, per tier-1 warp (TI-46, form (b), DA tab rev 96; OA's revs 262-268). OOE refuses no uop on ccv_dec_ooe_uop for a per-warp reason: FET holds CCV_P_DECQ_WARP_MAX credits a warp, counted in decode-queue slots, and picks a warp only while they cover the next instruction's slots, which it counts exactly by predecode (DEC asserts the count). credit_count is the slots of the slot's warp that left the decode queue this cycle: those renamed, and those a flush or rewind squashed, in the cycle they are dropped, so FET never resynchronises. An instruction needing more slots than the share borrows, only from full credits, into a 5-bit signed counter (OA's rev 263). HELD-AHEAD: after FET fetches a converged wait it marks all_waiting, the warp fetches at most CCV_P_HELD_AHEAD slots past it and never borrows. released clears that: OOE sets it in the cycle SYU's answer reaches it on ccv_syu_ooe_rel. A rewind beat (a squash of the wait, or a demotion) clears it at FET too. A message is sent for a slot only when credit_count or released is non-zero.

ooe → fet · rate 4 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `credit_count` | `CCV_W_DECQ_CREDIT` | 4 ⚠️ | CCV_W_DECQ_CREDIT (provisional) |
| `released` | `1` | 1 | literal |
| **total** | | **7** | ⚠️ 4 provisional |

### `ccv_rcu_ooe_done`

Completion back to the ROB for arithmetic -- and branch resolution: the condition is a predicate, which lives in RCU's file, so RCU resolves. branch_mask (issue mask AND guard) is what makes a branch divergence rather than a jump; branch_taken is any lane taking it. CCV_OP_PRF_COPY produces no done: its masked load keeps one rob_tag and one completion, the load's (A-38). Nor does any memop: a load or store completes on ccv_miu_ooe_cmpl alone, and RCU, which sends its address and writes a load's data, sends nothing here for it (OI-4, Daniel 2026-10-08). A done for a memop would spend a transfer and, arriving late, could match a reused rob_tag. CCV_DONE_SLOTS slots, a free pool (TI-9, OA's response 2026-10-09): dones arrive at fixed latency from ops issued in different cycles, so they stack by latency class. Four narrow lane ops issued at t - 7, an SFU op at t - 12, an RCU-only op at t - 3 and a warp-collective at t - 5 all land at t: seven. A lane op's done leaves the cycle its write lands, at V-35's bound with no slack, so none can wait for a slot. Memops send none (OI-4). No fault rides here: no cause of ISA v1.9 (§12) originates in RCU or a lane (AR's response IS-16), so exec_fault, fault_lane_mask and the lanes' sec_fault were removed. AR-24 (b), OA's revs 222, 223, 226: branch_mask is issue mask AND guard for a branch and for a barrier arrive, wait and wait.phase. For a ret, aux is the lowest active lane's rs (the target's offset in the ret's 4 GiB code window, ISA section 3) and branch_mask the active lanes whose rs equals it; OOE redirects those lanes to {PC[47:32] of the ret, aux} with stay = 1, and the ret re-issues for the rest, a pass per distinct target. For wait.phase, aux carries ps's lane bits, each lane's expected phase. Don't-care otherwise.

rcu → ooe · rate 7 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `branch_taken` | `1` | 1 | literal |
| `branch_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `aux` | `32` | 32 | literal |
| **total** | | **72** | ⚠️ 7 provisional |

### `ccv_rcu_miu_addr`

Address operands and store data for memory operations, and active_mask: issue mask AND guard predicate, computed by RCU, the one block holding both. The widest interface in the design. A predicate transfer (mem_op 4 or 5, TI-36) takes its one address from lane 0's base_per_lane whether or not lane 0 is active (O-62), and a predicate store's word, the predicate's 32 bits from RCU's predicate file, rides in store_data's lane 0 slot; active_mask is the issue mask, the merge mask. base_per_lane (TI-32, AR's response): each lane's base register, since only ld.pred and st.pred require a warp-uniform rbase (section 3); an O-30 frame pointer differs on every lane. A slot-form memop (slot_form on ccv_ooe_miu_memop) has no base register: base_per_lane is don't-care, and MIU takes the window from the CTA's launch block. SECTIONED (OI-33): base, index and store data are read at the memop's width and position, a slice, right-aligned in their fields; memop reads use their own PRF ports, never a lane port (CCV_PRF_MEMOP_READ_BITS).

rcu → miu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `active_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `base_per_lane` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `index_per_lane` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `store_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **3111** | ⚠️ 7 provisional |

### `ccv_miu_rcu_data`

Load return data written into the register file. active_mask (echoing rcu_miu_addr's) gates the write: an inactive lane keeps its old value. pred_result carries a per-lane predicate the memory op produces (cas's success), for RCU's predicate file. phys_dst and phys_pred echo the memop's, so RCU writes back without state: load_data to phys_dst, pred_result (cas's success) to phys_pred. pred_we, set by MIU from the op (cas, not a load), says whether pred_result is written at all -- without it a stateless RCU would clobber the predicate phys_pred names on every load. An L1 hit's data lands at the contracted cycle, with its completion (A-47). A predicate load (mem_op 4, TI-36) returns its word as pred_result with pred_we, and phys_dst the zero register (CCV_P_PHYS_ZERO), which no write reaches: it writes no GPR. Its copy-only op merges the predicate's inactive lanes in RCU. A masked load's inactive lanes are written by its copy-only op through a lane, never by MIU, so this channel carries no merge fields (A-33). SECTIONED (OI-29, OI-33): phys_dst is a row, dst_pos and dst_width the slice the load writes; load_data carries the slice right-aligned in each lane's 32 bits.

miu → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `active_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `pred_result` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `dst_pos` | `CCV_W_PHYS_POS` | 2 | CCV_W_PHYS_POS (arch) |
| `dst_width` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_we` | `1` | 1 | literal |
| `load_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1114** | ⚠️ 21 provisional |

### `ccv_miu_ooe_cmpl`

Completion, replay, fault and MLC miss. The miss indication is the primary demotion trigger, which is why it rides the completion path rather than its own channel. Every memop MIU accepts gets exactly one completion, including a store later bulk-discarded; the bulk-discard command itself gets none (A-41, A-53). An L1 hit completes at exactly CCV_LAT_L1_HIT; no completion at that cycle is the miss indication. Past L1 nothing is contracted, and scratchpad loads and atomics never wake dependants speculatively (A-46). ATOMIC PASSES (AR-21, OA's response): an atomic is A1 (atomic-read), A2 (the lane op) and A3 (atomic-write) under one rob_tag. MIU runs its lanes in passes, at most one lane per address in ascending lane order, and never waits for a line while holding another (V-72). A3's completion carries more = 1 while lanes remain, and OOE re-issues the three steps; more is 0 on every other completion. FAULTS (ISA v1.9 §12.5-12.6): on a faulting completion, cause is the highest-priority cause among the faulting lanes (F-ALIGN, F-ADDR, F-SHARED or F-RO, codes 5-8), address the lowest faulting lane's effective address, and lane_mask the faulting lanes; CRU's record takes exactly those. STATUS: 0 complete, 1 fault (cause and address carry the detail), 2 replay. REPLAY DRAIN (AR's and OA's responses TI-21, MIU spec rev 18): a load a bulk discard covers is completed at once with status replay, and MIU orphans its requests to DCU: their responses are dropped, with no write on ccv_miu_rcu_data after the completion (a data beat already started finishes first, and its completion may then carry its real status), no hint on ccv_miu_ooe_cmpl_hint, and its fill notice ignored. A discard that races a normal completion in the same cycle still yields exactly one completion (A-41). So a demotion's drain waits for no fill.

miu → ooe · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `rs_idx` | `CCV_P_W_RS_IDX` | 6 ⚠️ | CCV_P_W_RS_IDX (provisional) |
| `status` | `CCV_W_STATUS` | 2 | CCV_W_STATUS (arch) |
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `address` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `mlc_miss` | `1` | 1 | literal |
| `more` | `1` | 1 | literal |
| **total** | | **117** | ⚠️ 13 provisional |

### `ccv_ooe_miu_retire`

Commit or discard for the store buffer, so stores leave only after their instruction retires.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `commit_or_discard` | `1` | 1 | literal |
| **total** | | **8** | ⚠️ 7 provisional |

### `ccv_ooe_fet_redirect`

A mispredicted branch: the warp, its tier-1 stream, the branch's checkpoint, the lanes that took it, the target PC, and a fetch epoch so FET can discard in-flight fetches from the wrong path. RCU resolves (the condition is a predicate) and OOE compares the outcome with the prediction (pred_taken, A-42); OOE redirects only on a mispredict, at rate 1, serialising them deliberately (A-6). FET owns the PC-group state: it holds a checkpoint of it per unresolved branch (CCV_P_BR_CKPTS) and rebuilds the groups itself from checkpoint_id plus taken_mask, so OOE no longer resends group masks it does not own. Fixed latency (A-58): FET applies a redirect the cycle it lands and never stalls it, because ccv_ooe_fet_ckpt_free is latency-matched to this channel and the pair's arrival order must be its send order; FET applies a redirect before any free landing the same cycle. EPOCH OWNERSHIP (A-70, A-74): OOE owns every warp's fetch epoch and is the only block that advances it: on each redirect, on ccv_rau_ooe_demote, and on a kill. It tells FET of every change on this channel. A redirect carries the new epoch; a demotion or kill sends an epoch notice, epoch_only = 1, for which FET only takes fetch_epoch for warp_id, and checkpoint_id, taken_mask and target_pc are don't-care (no restore, no PC change, no checkpoint freed). FET advances nothing itself. It tags everything it fetches for the warp afterwards with that epoch on ccv_fet_dec_instr. Both blocks hold the epoch per warp_id, not per tier-1 slot, so it survives demotion and restore. Neither resets it at launch, because a relaunched warp_id could meet its predecessor's uops still in flight. The channel is fixed-latency and in order, so notices and redirects for a warp land in the order sent, and V-56 holds: one channel latency after every change, FET's epoch for a warp equals OOE's. REWIND (AR's and OA's responses TI-24 (3); FET spec, demotion rewind): on a demotion, after the epoch notice and the drain (CCV_DRAIN_WAIT), OOE sends one beat per group it holds, epoch_only = 1 and rewind = 1, naming in taken_mask the lanes whose oldest unretired entry, in the ROB or the decode queue, is at target_pc. FET sets those lanes' PCs to it; a lane in no beat keeps FET's PC, exact because the drain left nothing of it in flight, and min-PC merges what now coincides. checkpoint_id and fetch_epoch are don't-care on a beat. OOE sends ccv_ooe_rau_drained only once its last beat has landed in FET, at its send cycle plus this channel's fixed latency, so FET migrates the rewound PCs. A replayable fault (IS-4) uses the same beats. Here rather than a channel of its own: the beats need nothing the notice does not carry but one bit, and the fixed latency and order that make the notice safe. REWIND AND WAITS (TI-40, AR's rev 164, FET spec rev 22): a demotion's rewind beat of a warp OOE holds behind a converged wait sets rewind_held, and held_long gives that wait's length (0 16 bits, 1 32), so FET sets the beat's lanes to its PC less that length, back to the wait, which retired. FET rewinds its waiting lanes too: one named in no beat goes back by its own long bit; one named in a plain beat takes the beat's PC. OWN_PC (OA's rev 226, AR's rev 176, FET spec rev 24): set on a rewind_held beat when the held warp has no unretired uop, in the ROB or the decode queue. FET then rewinds the beat's lanes from its own PC, less the wait's length, and ignores target_pc. That is exact because the drain left nothing fetched past the wait, so OOE stores no PC for the case. FET asserts that an own_pc beat's lanes form one of its groups. 0 on every other beat. STAY (AR-24 (b), AR's rev 172, OA's rev 223, FET spec rev 23): set on every ret redirect. The branch's active lanes not in taken_mask stay at the ret's own PC rather than its fall-through, so the ret re-issues for them with their own targets. 0 on every other redirect.

ooe → fet · rate 1 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `checkpoint_id` | `CCV_P_W_CKPT_ID` | 2 ⚠️ | CCV_P_W_CKPT_ID (provisional) |
| `taken_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `target_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `fetch_epoch` | `CCV_P_W_FETCH_EPOCH` | 3 ⚠️ | CCV_P_W_FETCH_EPOCH (provisional) |
| `epoch_only` | `1` | 1 | literal |
| `rewind` | `1` | 1 | literal |
| `rewind_held` | `1` | 1 | literal |
| `held_long` | `1` | 1 | literal |
| `own_pc` | `1` | 1 | literal |
| `stay` | `1` | 1 | literal |
| **total** | | **114** | ⚠️ 5 provisional |

### `ccv_ooe_fet_ckpt_free`

Checkpoints freed by a correct branch resolution (A-56). One bit per tier-1 slot per checkpoint, bit tier1_id*CCV_P_BR_CKPTS + checkpoint_id; a set bit frees that checkpoint in FET. One message frees any number across all warps, so nothing queues: OOE sends whenever the mask is non-zero. A checkpoint is freed exactly once: here on a correct resolution, or by FET itself when a redirect restores it (FET frees the restored checkpoint and every younger one of that warp) or a demotion or kill resets the warp. OOE never frees a checkpoint the same cycle's redirect squashes, and drops the resolutions of squashed branches (A-58). Every set bit must name a checkpoint live in FET when it lands (V-46). Branches resolve out of order, which is why FET cannot infer frees from a count.

ooe → fet · rate 1 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `free_mask` | `CCV_TIER1_WARPS*CCV_P_BR_CKPTS` | 16 ⚠️ | CCV_TIER1_WARPS (arch); CCV_P_BR_CKPTS (provisional) |
| **total** | | **16** | ⚠️ 16 provisional |

### `ccv_spm_miu_rsp`

Scratchpad read data plus how many extra cycles conflicts cost, which the timing model needs.

spm → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_SPM` | 3 ⚠️ | CCV_P_W_REQ_MIU_SPM (provisional) |
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `conflict_serialization` | `CCV_W_CONFLICT_SER` | 6 | CCV_W_CONFLICT_SER (arch) |
| **total** | | **1033** | ⚠️ 3 provisional |

### `ccv_dcu_miu_rsp`

Cache read data, hit indication and whether ownership was granted, and mlc_miss: the fill that served this access missed in MLC (ccv_mlc_dcu_rsp.miss, passed through). MIU reports it on ccv_miu_ooe_cmpl, since an MLC miss is the primary demotion trigger; without this field the signal stopped at DCU (arch open A-9).

dcu → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_DCU` | 4 ⚠️ | CCV_P_W_REQ_MIU_DCU (provisional) |
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `hit` | `1` | 1 | literal |
| `ownership_granted` | `1` | 1 | literal |
| `mlc_miss` | `1` | 1 | literal |
| **total** | | **1031** | ⚠️ 4 provisional |

### `ccv_mlc_dcu_rsp`

Line fills and ownership grants back to L1.

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_DCU_MLC` | 4 ⚠️ | CCV_P_W_REQ_DCU_MLC (provisional) |
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1030** | ⚠️ 1028 provisional |

### `ccv_mlc_dcu_probe`

Inbound invalidate or downgrade. Unsolicited, and a wake source, since a sleeping D-cache must still answer.

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MLC_PROBE` | 2 ⚠️ | CCV_P_W_REQ_MLC_PROBE (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `invalidate_or_downgrade` | `1` | 1 | literal |
| **total** | | **51** | ⚠️ 50 provisional |

### `ccv_dcu_mlc_probe_ack`

Probe response, carrying dirty data when the line was modified.

dcu → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MLC_PROBE` | 2 ⚠️ | CCV_P_W_REQ_MLC_PROBE (provisional) |
| `ack` | `1` | 1 | literal |
| `dirty_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1027** | ⚠️ 1026 provisional |

### `ccv_fet_mlc_ifill`

Instruction cache miss straight to MLC, bypassing the D-cache. Physically addressed, so no ASID (arch open A-5).

fet → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_FET_MLC` | 2 ⚠️ | CCV_P_W_REQ_FET_MLC (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| **total** | | **50** | ⚠️ 50 provisional |

### `ccv_mlc_fet_ifill_rsp`

Instruction line fill.

mlc → fet · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_FET_MLC` | 2 ⚠️ | CCV_P_W_REQ_FET_MLC (provisional) |
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1026** | ⚠️ 1026 provisional |

### `ccv_rau_ooe_alloc`

What RAU tells OOE about a warp's residency (A-64, A-65). alloc_op: 0 free, 1 launch, 2 restore-allocate, 3 restore-activate. Launch: OOE maps the warp's 16 architectural GPRs and 4 predicates to the hardwired zero registers (CCV_P_PHYS_ZERO, CCV_P_PRED_ZERO), so no zeroing traffic is sent and the warp may issue at once. Restore-allocate, before the PCA transfer: OOE allocates 16 GPRs and 4 predicates from the slot's reservation, so it never waits, and sends ccv_ooe_rcu_map with direction 1. Restore-activate, after ccv_pca_rau_mig_done: only now may the warp rename and issue. A single activation message would deadlock, since PCA's rows need the map and the map would need the activation. Free: the warp's state is released. tier1_id is the tier-1 slot RAU placed the warp in; OOE keeps its warp-to-slot table from it, which indexes the ROB, rob_tag's slot field, the per-slot reservations and the checkpoint-free bitmap, so ccv_dec_ooe_uop needs no slot field. Identity: ctaid and warp_in_cta, which OOE shadows so it can put srd's value in the immediate at issue (Q-38, A-25). RAU allocates no physical registers: OOE's global free lists do, from a reservation held per tier-1 slot whether occupied or not, so activation never waits and no credit is withheld (A-30, A-49). RAU's table is indexed by warp slot, which does not change while a warp parks, so identity stays out of the parked context by design. BARRIERS (IS-16, ISA v1.9 O-59): on a launch and on a restore-allocate, barrier_count is the warp's CTA's allocated barrier count, 0 to 16. OOE holds it in the tier-1 slot's state and raises F-BARRIER at dispatch for a barrier instruction whose ID is at or above it, so a faulting reference never reaches SYU. It rides restore-allocate too because a restored warp can land in a different slot, and RAU, which owns the CTA's allocation, is the one holder that survives demotion (OA's response IS-16). CTA SLOT (TI-34, AR's and OA's responses): on a launch and on a restore-allocate, cta_slot is the CTA slot RAU gave the warp's CTA. OOE holds it per tier-1 slot, beside barrier_count, and stamps it onto ccv_ooe_miu_memop, ccv_ooe_syu_bar and ccv_ooe_cru_fault, whose per-CTA state (F-SHARED's and F-RO's bounds, the launch-slot windows, SYU's barrier counts) is indexed by it. A parked warp keeps its CTA slot at RAU, so a restore-allocate carries it again and nothing migrates. Don't-care on free and restore-activate.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `alloc_op` | `2` | 2 | literal |
| `ctaid` | `CCV_W_CTAID` | 32 | CCV_W_CTAID (isa) |
| `warp_in_cta` | `CCV_W_WARP_IN_CTA` | 5 | CCV_W_WARP_IN_CTA (isa) |
| `barrier_count` | `CCV_L_W_BAR_COUNT` | 5 | CCV_L_W_BAR_COUNT (isa) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| **total** | | **54** | ⚠️ 3 provisional |

### `ccv_ooe_rcu_map`

Where a migrating warp's architectural registers live: its RAT, 16 physical GPR names and 4 physical predicate names. Physical locations exist only in OOE's RAT, so this replaces RAU's prf_base + arch addressing. direction 0: demote, RCU reads the named rows out to PCA; 1: restore, RCU writes PCA's rows into them. RCU pairs it with ccv_rau_rcu_mig by warp and direction (A-45), and ccv_ooe_rau_drained is sent only after it. Rate 1, separate from the issue channel, whose nine resource slots bind the machine's width. A message is one whole map, atomic and ordered by construction on a single slot, so no slot attributes are declared (the schema refuses them on a rate-1 channel). A demotion map may name the zero registers (A-64): RCU then reads zeros out to PCA. A restore map never does: restore-allocate allocates every register it names. SECTIONED (OI-29, TI-9): a register is a row, a position and a width, so gpr_pos and gpr_width ride beside gpr_map. Rows are warp-private, so demotion and restore move whole rows (OA's response TI-9 (2)). One row per architectural register (AR's and OA's responses TI-25 (1)): Ra moves as mig_row a, R0 to R15 and then the predicate row, 17 rows whatever the map shares, with no merging of shared or zero rows; a register naming the zero register moves a row of zeros. A restore map gives each register a row of its own, and RCU writes row a into Ra's. OOE keeps each register's position and committed width per warp while it is parked (64 bits a warp) and restores them on the restore map. Sharing and zero elision are deferred (PF-40).

ooe → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `gpr_map` | `CCV_GPRS*CCV_P_W_PHYS_REG` | 128 ⚠️ | CCV_GPRS (isa); CCV_P_W_PHYS_REG (provisional) |
| `gpr_pos` | `CCV_GPRS*CCV_W_PHYS_POS` | 32 | CCV_GPRS (isa); CCV_W_PHYS_POS (arch) |
| `gpr_width` | `CCV_GPRS*CCV_W_CHWIDTH` | 32 | CCV_GPRS (isa); CCV_W_CHWIDTH (isa) |
| `pred_map` | `CCV_PREDS*CCV_P_W_PHYS_PRED` | 24 ⚠️ | CCV_PREDS (isa_provisional); CCV_P_W_PHYS_PRED (provisional) |
| **total** | | **222** | ⚠️ 152 provisional |

### `ccv_fet_pca_mig`

A demoted warp's divergence state, out to the parked array: each lane's PC within the warp's window (CCV_W_LANE_PC bits, lane 0 at the LSBs), the PC bits above the window that every lane shares, the fairness rule's lane pointer and pick counter (DA's response IS-17), and live_mask, the lanes that have not exited (AR's response TI-27 (b)). FET's live mask is speculative: fetching an exit clears its group's lanes, every lane a rewind beat names is live again, and a mispredict restores the mask from the branch's checkpoint. After the demotion's beats it is exact, so FET sends it then. The fairness state is not the boundary's, which FET cannot know (TI-27 (c)): FET keeps its pointer, moved on to the next live lane if it names none, and sets the counter to CCV_FAIR_N, so lane r's group takes the first pick after the restore. Groups are the lanes with equal PCs; nothing else of FET's needs to move. FET owns the PCs, so they migrate from FET directly, not through RCU, which would cross two blocks and hold state it has no other reason to touch. FET sends it once OOE's rewind beats have set the PCs to the retirement boundary (TI-24 (3)). RAU sequences this and the RCU to PCA transfer; PCA acks both halves at once on ccv_pca_rau_mig_done. Checkpoints never migrate: demotion squashes to the retirement boundary, so a demoted warp has no unresolved branch. Its trace identity, trace-only like every channel's, is the instruction the warp resumes at, its retirement boundary (class instr, not none like the other migration channels): a trace-driven FET resumes there in the oracle's order, and the trace shows where each restored warp picked up (TI).

fet → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `lane_pcs` | `CCV_WARP_LANES*CCV_W_LANE_PC` | 992 | CCV_WARP_LANES (isa); CCV_W_LANE_PC (arch) |
| `pc_upper` | `CCV_W_PC_UPPER` | 16 | CCV_W_PC_UPPER (arch) |
| `fair_ptr` | `CCV_W_FAIR_PTR` | 5 | CCV_W_FAIR_PTR (arch) |
| `fair_cnt` | `CCV_W_FAIR_CNT` | 6 ⚠️ | CCV_W_FAIR_CNT (provisional) |
| `live_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **1056** | ⚠️ 6 provisional |

### `ccv_pca_fet_mig`

A restored warp's divergence state back to FET, in ccv_fet_pca_mig's layout: per-lane PCs, the shared upper bits, the fairness pointer and counter, and the live lanes. FET resumes fetch from them. Its trace identity, trace-only like every channel's, is the instruction the warp resumes at, its retirement boundary (class instr, not none like the other migration channels): a trace-driven FET resumes there in the oracle's order, and the trace shows where each restored warp picked up (TI).

pca → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `lane_pcs` | `CCV_WARP_LANES*CCV_W_LANE_PC` | 992 | CCV_WARP_LANES (isa); CCV_W_LANE_PC (arch) |
| `pc_upper` | `CCV_W_PC_UPPER` | 16 | CCV_W_PC_UPPER (arch) |
| `fair_ptr` | `CCV_W_FAIR_PTR` | 5 | CCV_W_FAIR_PTR (arch) |
| `fair_cnt` | `CCV_W_FAIR_CNT` | 6 ⚠️ | CCV_W_FAIR_CNT (provisional) |
| `live_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **1056** | ⚠️ 6 provisional |

### `ccv_rau_miu_cta`

Per-CTA scratchpad bounds and the launch block address, so MIU can check F-SHARED and service launch-block reads. The CTA's .shared region is SPM bytes spm_base to spm_limit, both included, so a region may end at SPM's last byte within CCV_W_SPM_ADDR. A .shared address is the CTA-relative offset, modulo 2^32 (CP-33). MIU raises F-SHARED, cause 7, on any active lane whose bytes do not all lie within offset 0 to spm_limit - spm_base. It ranks after F-ADDR, which no .shared access can raise, and before F-RO, which only .global can raise (section 12.5). SPM's byte address is spm_base plus the offset (TI's rev 230). F-RO (O-51, O-61; AR's responses TI-26, revs 124-126): const_base and const_limit are the module's .const range, flat addresses (O-54), half-open [const_base, const_limit); equal, the range is empty. They come from the grid's descriptor (Q-50), set by its module, so they are per CTA. MIU raises F-RO, cause 8, on any lane in active_mask of a store or atomic any byte of which lies in that range or in the launch window, window 2 (address bits [47:16] equal to 2; the whole window is read-only, ISA section 5.2), compared on the effective address before MIU maps it. Loads are unaffected. F-RO is last among the execute causes (section 12.5). The instruction then has no effect on any lane: a store puts nothing committable in the store buffer, and an atomic sends no exclusive request. The completion's lane_mask is the faulting lanes, and its address the lowest such lane's. LOCAL_BASE (TI-47; AR's rev 253, MIU spec rev 44, RAU spec rev 33): the context's local_base, launch-block word 24, a window index, sent at dispatch from the launch descriptor. MIU forms from it, at the CTA's arrival, both O-69's spill-space base (local_base + CCV_LANE_CONTEXTS) and O-83's run base W = local_base + %privoff, so O-83's decision on a .global memop's rbase never waits for the launch block's line, and a local-form access no longer fills it.

rau → miu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `spm_base` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `spm_limit` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `launch_block_addr` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `const_base` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `const_limit` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `local_base` | `CCV_W_VA - 16` | 48 | CCV_W_VA (arch) |
| **total** | | **277** | ⚠️ 3 provisional |

### `ccv_ooe_syu_bar`

Barrier reports at retire (TI-40: AR's revs 161-164, OA's revs 200-204, DA 2026-10-23). OOE sends one for every retired bar.arrive, bar.wait and bar.wait.phase, and for every retired exit, partial or final; nothing leaves OOE before it retires, so no report is recalled. bar_kind: 0 arrive, 1 wait, 2 wait.phase, 3 exit. issue_mask is the uop's issue group; guard_mask its guard's lanes (all ones for an unguarded uop): an arrive's arriving lanes are issue_mask & guard_mask, an exit's exiting lanes issue_mask. A wait's lanes ask SYU for its answer; wait.phase's phase_mask is each lane's expected phase, its predicate source read at issue (O-27). held (DA's PF-44 variant, AR's rev 163/164): the wait carried FET's all_waiting mark, so its warp is converged and OOE holds rename behind it; SYU answers a held wait on ccv_syu_ooe_rel and every other wait per lane on ccv_syu_fet_rel. barrier_id is don't-care on an exit. SYU keeps the arrived lanes per (warp context, barrier id) and the live lanes per context, from the launch and the exits (SYU spec rev 7). A warp may be demoted while waiting, so the table tracks non-resident warps.

ooe → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| `bar_kind` | `2` | 2 | literal |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `guard_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phase_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `held` | `1` | 1 | literal |
| **total** | | **111** | ⚠️ 3 provisional |

### `ccv_rau_syu_alloc`

Barrier entries and residency at SYU (TI-40, AR's revs 159 and 161). syu_alloc_op: 0 free (the CTA's last warp gone: its entries and slot), 1 allocate (a CTA admitted whole: barrier_base and barrier_count, the launch's, 0 to 16; warp_mask the CTA's warp contexts; warp_id its last warp and last_lanes that warp's live lanes less one, every other warp's 32, so SYU's live lanes start from the launch), 2 demote (warp_id leaves residency: SYU answers its waits on ccv_syu_rau_ready, at once if it has no waiting lanes), 3 restore (warp_id is resident again). Exits clear live lanes through OOE's exit reports on ccv_ooe_syu_bar, the final exit's included, so there is no exit op.

rau → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_base` | `CCV_W_BAR_ENTRY` | 6 | CCV_W_BAR_ENTRY (arch) |
| `barrier_count` | `CCV_L_W_BAR_COUNT` | 5 | CCV_L_W_BAR_COUNT (isa) |
| `syu_alloc_op` | `2` | 2 | literal |
| `warp_mask` | `CCV_WARP_CONTEXTS` | 32 | CCV_WARP_CONTEXTS (arch) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `last_lanes` | `CCV_W_LANE_IDX` | 5 | CCV_W_LANE_IDX (arch) |
| **total** | | **58** | ⚠️ 3 provisional |

### `ccv_ooe_cru_fault`

The first fault taken by a context, written once and never overwritten.

ooe → cru · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `address` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| **total** | | **172** | ⚠️ 3 provisional |

### `ccv_dcu_miu_fill_ntc`

A refill notice (OA-23; AR's response TI-23): DCU promises that the refill answering req_id leaves on the same slot of ccv_dcu_miu_rsp with its valid exactly CCV_LAT_FILL_NOTICE cycles after this notice's payload lands. DCU keeps the promise by reserving that slot and its credit, and a probe never cancels a promised response (DCU spec, Internals). Optional: a refill without a notice is legal and only wakes its dependants late. MIU uses it to send OOE's completion hint in time (ccv_miu_ooe_cmpl_hint). A channel of its own rather than a second valid in the response's slot: a notice is a message with its own valid, and as a channel its payload register is enabled by its own valid flop (CG-5), with no lead slice.

dcu → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_DCU` | 4 ⚠️ | CCV_P_W_REQ_MIU_DCU (provisional) |
| **total** | | **4** | ⚠️ 4 provisional |

### `ccv_miu_ooe_cmpl_hint`

A completion hint (OA-23; AR's response TI-23): MIU promises that the completion of rob_tag, waking RS entry rs_idx, leaves on the same slot of ccv_miu_ooe_cmpl with its valid exactly CCV_LAT_CMPL_HINT cycles after this hint's payload lands, so OOE's wake lines can rise two cycles ahead of the completion as its scheduler loop needs (OI-45). MIU keeps it by reserving the completion's slot and credit, and those of the load's data on ccv_miu_rcu_data (MIU spec, Mechanisms). Optional: a completion without a hint wakes a cycle late. rob_tag, not a generation bit, tells a stale hint: OOE acts only if that ROB slot is not squashed-pending (AR's rev 94, OA's rev 141).

miu → ooe · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rs_idx` | `CCV_P_W_RS_IDX` | 6 ⚠️ | CCV_P_W_RS_IDX (provisional) |
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| **total** | | **13** | ⚠️ 13 provisional |

## ⛔ Carries a preliminary width

### `ccv_dec_ooe_uop`

Format-decoded operations with architectural register names (src_arch holds two sources and src2_arch the third -- Format A's rs2, an independent source such as mad.lo's and dp4's accumulator input; dst_arch is the destination, always), the predicate guard and the predicate destination as separate fields (pred_guard with pred_neg, pred_dst with pred_we: ISA Format C carries them in separate fields, so @P0 setp P1 is one instruction), the immediate and scale enable, six per cycle into the queue ahead of rename. imm is always the architectural immediate: a branch's is its encoded halfword offset from the next instruction, and ilen (the instruction length code, as on ccv_fet_dec_instr) rides beside it, so OOE computes the target as pc + bytes(ilen) + 2 * imm rather than DEC folding the length in (arch open A-8). checkpoint_id and pred_taken pass through from FET on a branch: OOE compares RCU's resolved outcome with pred_taken to detect a mispredict, then names the checkpoint on ccv_ooe_fet_redirect (A-42). sched_attr (A-66): the scheduling attributes, decoded by DEC so OOE never decodes opcode, whose encoding is preliminary and expected to churn. The three fields A-75 asked for (TI-1, agreed by Daniel 2026-10-08), so OOE never decodes opcode: src_valid[3], bit i set when source i is a real read (bits 0 and 1 the two fields of src_arch, bit 2 src2_arch), so OOE renames and waits on nothing else; pred_use[2], how the predicate is read: 0 none, 1 guard (an enable: switched-off lanes keep their old value, so merge_en is set, and a masked load owes its copy), 2 data (sel's selector: no merge); imm_kind[3], what imm holds: 0 a literal, 1 predicate logic's two sources (qualifiers in imm[5:0], [2:0] and [5:3], each [1:0] the architectural predicate and [2] its negate), which OOE renames and rewrites on ccv_ooe_rcu_issue, 2 srd's warp_base identity, 3 srd's ctaid identity, 4 srd #2's %lanectx (ISA v1.9 O-64; OA's response TI-33): ((CCV_P_CORE_ID << CCV_W_WARP_ID) | hardware warp context) << 5, the context being warp_id, which a warp keeps while parked, so its spill space and its O-83 region never move, 5 srd #3's %privoff (ISA v1.9 O-83; DA tab rev 95): 3 * CCV_LANE_CONTEXTS, the O-83 run's offset from local_base in windows, the same on every lane, warp and CTA. OOE substitutes each; the lane ORs its index into 2 and 4, and passes 3 and 5 through. Exit is sched_attr's serial code 3. A guard or data use is never bypassed, and OA adds that pred_use feeds the A-62 late bit. Layout MSB first: bypass_group[3], rs_miu, exec_rcu, cross_lane, writes_gpr, writes_pred, mem_kind[2], branch, serial[3], lat_class[3] (CCV_P_W_SCHED_ATTR has the codes). lat_class sets a producer's full latency; bypass_group, as producer and as consumer, indexes the bypass table, whose penalties are parameters (OI-16, Daniel's responses OA-4). DEC owns the opcode-to-attribute table. mem_op, space and ordering (A-68) are decoded here too, for memory ops, and OOE copies them to ccv_ooe_miu_memop unexamined, so opcode decoding lives only in DEC and MIU stays off the opcode census. DEC never emits mem_op 0xF, which is OOE's bulk discard (A-41); asserted on DEC's output (V-52). mem_op and space are don't-care unless sched_attr's rs_miu is set, as is mem_kind; ordering is reserved zero except on a fence (rs_miu with mem_kind fence), which OOE refuses otherwise (IS-11). group_mask and fetch_epoch pass through from FET (A-69, A-70): OOE renames no uop whose fetch_epoch differs from its warp's current epoch, and every issued uop's issue_mask is the group_mask it arrived with. The mask rides per slot. Sharing it once per warp was considered and dropped (A-72): it saves about 10% of ccv_fet_dec_instr's wires and at most 5% of this channel's, and here it would also need the freely bound slots regrouped by warp and a field shared across a slot group. FAULTS (ISA v1.9 §12; AR's and IS's responses IS-16): cause is the uop's fault cause, CCV_W_FAULT_CAUSE's code: 1 F-FETCH when FET's fetch_fault came with the instruction, else 2 F-ILLEGAL from DEC's own check, else 0. Fetch beats decode, settled here where both are known, and the ROB keeps one cause per entry, the lower code winning (§12.5). F-FORMAT (OI-57, OA's response): OOE stays opcode-blind (A-66), so DEC's table sends the format decoded, not the format code. fmt_rsv has one bit per chwidth code, bit i for code i (0 = 32, 1 = 16, 2 = 8, 3 = 4 bits), set where this op's format code is reserved at that width: codes 10 and 11 at every width, 01 at 32 and 4 bits (ISA v1.9 §4). It is 0 for an op with no format field. fmt_opnd names the operand whose committed width selects the bit: 0 src0, 1 src1, 2 src2, 3 the destination. OOE raises F-FORMAT (cause 4) at rename when fmt_rsv[width(fmt_opnd)] is set, from its committed per-register width table. F-WIDTH needs no field of its own beyond xfer_size and all_waiting (below): a memory access's rdata is the destination for a load and the data source for a store (mem_kind). A store's data source is always src_arch's first register, its base and then its index following it, so OOE takes a store's data register, its width code and its MIU pipes from that first source (AR-24 (d)). final_exit passes through from FET (TI-27): the warp has exited when the uop carrying it retires, so OOE holds no live mask. slot_form and arg_slot (TI-31, AR's response): a memory op in Format D's launch-slot mode (O-45) sets slot_form, and arg_slot is its 4-bit launch slot, an immediate where the base register would be; decoded here and copied by OOE to ccv_ooe_miu_memop unexamined, as mem_op and space are. Zero for every other op. PREDICATE TRANSFERS (TI-36, AR's and OA's responses): DEC cracks ld.pred and st.pred into one uop per predicate of the mask, ascending, uop k moving Pk's word at disp + 4k of the 16-byte frame, mem_op 4 (load) or 5 (store). ld.pred's uop names Pk in pred_dst with pred_we; st.pred's names it in pred_guard with pred_use data (2), never a guard. Each uop is idempotent, so a squash or demotion after a partial retirement re-runs the instruction from its first uop. local_form (IS-19, adopted by DA 2026-10-23; ISA v1.9 O-69; OA's response IS-19): a memory op in Format D's interleaved local mode, ld.local, st.local, ld.pred.local or st.pred.local, sets local_form. It names no base register, so src_valid marks none and OOE renames no base: ld.local's only GPR is its destination, st.local's its data. imm is the unsigned 17-bit byte offset b, and space is global. The predicate forms crack as ld.pred and st.pred do, uop k at b + 4k, mem_op 4 or 5. OOE copies local_form to ccv_ooe_miu_memop unexamined, as slot_form. Zero for every other op. all_waiting passes through from FET (TI-40): on a wait (serial 2) it marks a converged wait, which OOE holds rename behind and reports with held set; on a marked wait or exit it starts the barrier demotion timer at retire. On a chwidth (serial 1, or a chwidth.multi sibling) it means converged instead (O-81, DA tab rev 91): FET sets it when the chwidth's group is every live lane, and DEC copies it to every sibling of a cracked chwidth.multi. A chwidth with it clear raises F-WIDTH at dispatch, precisely and predicate-independently, so a diverged chwidth.multi faults whole at its first sibling. It starts no timer on a chwidth. XFER_SIZE and XFER_SIGNED (O-80, DA tab rev 90; DEC spec rev 13): a sized load or store's transfer, from DEC's table, since OOE never decodes the opcode (A-66). xfer_size is 0 for rdata's width, as before, 1 for one byte or 2 for two. xfer_signed sign-extends a sized load (ld.s8, ld.s16). Both are 0 on every other uop. F-WIDTH gains O-80's case: a sized transfer wider than rdata's committed width faults, that is a byte into nothing narrower than 8 bits, or a halfword into nothing narrower than 16. rdata at 4 bits faults as before, for every memory access. Rename, placement, footprint and the width codes follow rdata's width as ever. SERIAL is 3 bits (TI-41, OA's rev 198): 0 none, 1 chwidth, 2 barrier wait (bar.wait, bar.wait.phase), 3 exit, 4 barrier arrive (bar.arrive: no rename hold, reported at retire), 5-7 spare.

dec → ooe · rate 6 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `group_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `fetch_epoch` | `CCV_P_W_FETCH_EPOCH` | 3 ⚠️ | CCV_P_W_FETCH_EPOCH (provisional) |
| `uop_class` | `CCV_L_W_CLASS` | 3 ⛔ | CCV_L_W_CLASS (preliminary, churn low) |
| `sched_attr` | `CCV_P_W_SCHED_ATTR` | 21 ⛔ | CCV_P_W_SCHED_ATTR (preliminary, churn med) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `space` | `CCV_L_W_SPACE` | 1 | CCV_L_W_SPACE (isa) |
| `ordering` | `CCV_L_W_ORDERING` | 5 | CCV_L_W_ORDERING (isa) |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `src_arch` | `2*CCV_W_ARCH_REG` | 8 | CCV_W_ARCH_REG (isa) |
| `src2_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `dst_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `pred_guard` | `CCV_W_ARCH_PRED` | 2 | CCV_W_ARCH_PRED (isa) |
| `pred_neg` | `1` | 1 | literal |
| `pred_dst` | `CCV_W_ARCH_PRED` | 2 | CCV_W_ARCH_PRED (isa) |
| `pred_we` | `1` | 1 | literal |
| `src_valid` | `3` | 3 | literal |
| `pred_use` | `2` | 2 | literal |
| `imm_kind` | `3` | 3 | literal |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `ilen` | `CCV_W_ILEN` | 2 | CCV_W_ILEN (isa) |
| `checkpoint_id` | `CCV_P_W_CKPT_ID` | 2 ⚠️ | CCV_P_W_CKPT_ID (provisional) |
| `pred_taken` | `1` | 1 | literal |
| `scale_en` | `1` | 1 | literal |
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `fmt_rsv` | `2**CCV_W_CHWIDTH` | 4 | CCV_W_CHWIDTH (isa) |
| `fmt_opnd` | `2` | 2 | literal |
| `final_exit` | `1` | 1 | literal |
| `all_waiting` | `1` | 1 | literal |
| `slot_form` | `1` | 1 | literal |
| `arg_slot` | `4` | 4 | literal |
| `local_form` | `1` | 1 | literal |
| `xfer_size` | `2` | 2 | literal |
| `xfer_signed` | `1` | 1 | literal |
| **total** | | **236** | ⛔ 37 preliminary, ⚠️ 37 provisional |

### `ccv_ooe_rcu_issue`

What the scheduler selected: physical register names (three sources; the guard predicate and the predicate destination separately, with pred_we saying whether a predicate is written), opcode, element width, the issue group's lane mask, and the ALU immediate, which RCU substitutes into an operand slot at register read so lanes never see an immediate. One slot per select resource (CCV_ISSUE_RESOURCES = 9): S0-S3, P0-P3, R; see SECTIONED LANES below. MERGE (A-33): with merge_en set (the issue mask is not full or the op is guarded), phys_old_dst is a fourth source, read at issue with the others and carried to the lane as merge_data, so it bypasses like any operand; the lane writes its inactive lanes from it. merge_en = 0 makes phys_old_dst don't-care. Predicates merge in RCU instead: at write-back RCU read-modify-writes the 32-bit row from phys_pred_old_dst (A-43). A masked load sends a second, copy-only op here, opcode CCV_OP_PRF_COPY = 0x1FF, with the load's rob_tag: it writes only the load's inactive lanes (GPR and predicate destination alike) and produces no done (A-38). Fixed latency: once RCU accepts an issue the result lands at the contracted latency, and there is no port grant (Q-51, A-28). ZERO REGISTERS (A-64): CCV_P_PHYS_ZERO and CCV_P_PRED_ZERO, one past each pool, read zero and are never written. A read of one needs no PRF port: RCU decodes the index and drives a constant, which matters because a launched warp's early reads all name them (A-73). A launched warp's sources, guard and old destinations may name them; phys_dst, phys_pred_dst and the destinations of every write never do. PREDICATE LOGIC (TI-1): pand, por and pxor read two predicates, and OOE renames them like any source, so imm carries their physical names, not DEC's qualifiers: [CCV_P_W_PHYS_PRED-1:0] the first source, [CCV_P_W_PHYS_PRED] its negate, then the second source and its negate, 2 (CCV_P_W_PHYS_PRED + 1) = 14 bits. RCU reads them as it reads phys_pred_guard, so the issue channel does not grow. SECTIONED LANES (Daniel's responses OI-28 to OI-31, change doc 'Interface spec changes -- sectioned lanes', TI-9): a lane is four 8-bit sections and the PRF four section banks; a register name is a row (phys_src, phys_src2, phys_dst, phys_old_dst) plus a position (src_pos, dst_pos, old_dst_pos), each operand with its own width code (src_width; dst_width, which the merge source shares, being the same architectural register). footprint is the op's 4-bit mask: lane sections for an op on S0-S3 (the union of its operands' sections, widened to CCV_FOOT_MIN for its bypass_group; a non-contiguous mask is legal), MIU pipes for a memop on P0-P3, 0 on R. An op sits in its footprint's lowest slot; every other slot of its footprint carries cont = 1 and the same rob_tag, and nothing else. A memop takes P slots here, for RCU to read its operands at its width and position, as well as its pipe footprint on ccv_ooe_miu_memop. Co-issued footprints are disjoint (V-60), so at most one full-width lane op, one full-width memop and one RCU op issue in a cycle, and four 8-bit ops of each. The zero register is valid at any position. bypass_group rides with the op for the lanes' forwarding (OI-16).

ooe → rcu · rate 9 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phys_src` | `2*CCV_P_W_PHYS_REG` | 16 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_src2` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_old_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred_guard` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_neg` | `1` | 1 | literal |
| `phys_pred_dst` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `phys_pred_old_dst` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_we` | `1` | 1 | literal |
| `merge_en` | `1` | 1 | literal |
| `cont` | `1` | 1 | literal |
| `footprint` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| `bypass_group` | `CCV_P_W_BYP_GROUP` | 3 ⛔ | CCV_P_W_BYP_GROUP (preliminary, churn med) |
| `src_pos` | `3*CCV_W_PHYS_POS` | 6 | CCV_W_PHYS_POS (arch) |
| `src_width` | `3*CCV_W_CHWIDTH` | 6 | CCV_W_CHWIDTH (isa) |
| `dst_pos` | `CCV_W_PHYS_POS` | 2 | CCV_W_PHYS_POS (arch) |
| `old_dst_pos` | `CCV_W_PHYS_POS` | 2 | CCV_W_PHYS_POS (arch) |
| `dst_width` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `dispatch_fault` | `1` | 1 | literal |
| **total** | | **175** | ⛔ 12 preliminary, ⚠️ 97 provisional |

### `ccv_rcu_lane_ops`

Operands and control to one lane, one message a cycle (Daniel's response OI-28; change doc 'Interface spec changes -- sectioned lanes'). A lane is four 8-bit sections, S0-S3, and up to four ops share the message, each in its own sections. operand (three 32-bit ports, src0-src2) and merge_data (the fourth) are the four operand ports, 32 bits a lane: one byte a section, each from its own section bank. Per section: section_en (an op holds it), sec_owner (the lead section, its lowest, of the op that holds it; a section is its op's lead where sec_owner names itself), sec_opcode, sec_pred_bit and sec_pred_data. An owner rather than a lead bit, because a footprint may be non-contiguous (AR-15): ops on {S0, S2} and {S1, S3} share a message, and a lead bit alone cannot say whose S2 is (TI-10). On a lead section only: each of the four operands' position and width (sec_opnd_pos, sec_opnd_width) and the destination's (sec_dst_pos, sec_dst_width). The op routes bytes freely within its footprint as part of executing, the swizzle, after the bypass mux; it never reaches another lane's word, which only a warp-collective in RCU moves. A full-width op holds all four sections. sec_pred_bit is the section op's ENABLE in this lane: issue mask AND guard, the same computation as active_mask. A section whose enable is clear does not compute: its op returns merge_data's bytes as its result, which is how a masked or guarded write keeps its inactive lanes' old values under rename (A-33, A-44); merge_data is don't-care when the op's merge_en is 0. For CCV_OP_PRF_COPY an enabled lane's result is don't-care: RCU writes only the inactive lanes. sec_pred_data is a predicate read as DATA, e.g. sel's selector. What reaches a lane: every opcode with a per-lane input, a GPR or the lane's own hardwired index (Q-32, Q-38). RCU executes the opcodes whose inputs are all warp-level -- predicate logic, pmov, movi, movi48, branch resolution -- plus the horizontal ops (shfl, vote, ballot, unballot). setp, add.pp and cas run in lanes although they write predicates; sec_pred_out carries those back. srd runs in the lane: selector 0 ORs the lane's index into the warp_base immediate, selector 1 passes %ctaid through, decoded from the selector by DEC as two opcodes. operand_byp is the lane-local bypass (A-59, TI-8, TI-9): one CCV_P_W_LANE_BYP_SEL select per operand port per section, since co-issued narrow ops may each forward from a different producer. A select with its forward bit set replaces that section's byte of that port with a result this lane computed earlier, named by the producer's lead section and its age, the cycles between the two messages' arrival here less CCV_LAT_LANE_BYP. RCU sets it for a source whose lane producer has not yet written the PRF, which only a dependant woken at a bypass offset can meet. The selects are the same on every lane, like the opcodes. LAYOUT: every per-section field packs S0 at its LSBs. sec_opnd_pos, sec_opnd_width and operand_byp hold one entry per port per section, section-major: entry k * (CCV_L_OPERANDS_PER_LANE + 1) + i is section k's port i, ports src0-src2 then merge_data. sec_opnd_pos, sec_opnd_width, sec_dst_pos and sec_dst_width are read on lead sections only.

rcu → lane · rate 1 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `sec_opcode` | `CCV_SECTIONS*CCV_L_W_OPCODE` | 36 ⛔ | CCV_SECTIONS (arch); CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `operand` | `CCV_L_OPERANDS_PER_LANE*CCV_W_LANE_DATA` | 96 ⛔ | CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_LANE_DATA (isa) |
| `merge_data` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `section_en` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| `sec_owner` | `CCV_SECTIONS*CCV_W_PHYS_POS` | 8 | CCV_SECTIONS (arch); CCV_W_PHYS_POS (arch) |
| `sec_pred_bit` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| `sec_pred_data` | `CCV_SECTIONS` | 4 | CCV_SECTIONS (arch) |
| `sec_opnd_pos` | `CCV_SECTIONS*(CCV_L_OPERANDS_PER_LANE+1)*CCV_W_PHYS_POS` | 32 ⛔ | CCV_SECTIONS (arch); CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_PHYS_POS (arch) |
| `sec_opnd_width` | `CCV_SECTIONS*(CCV_L_OPERANDS_PER_LANE+1)*CCV_W_CHWIDTH` | 32 ⛔ | CCV_SECTIONS (arch); CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_CHWIDTH (isa) |
| `sec_dst_pos` | `CCV_SECTIONS*CCV_W_PHYS_POS` | 8 | CCV_SECTIONS (arch); CCV_W_PHYS_POS (arch) |
| `sec_dst_width` | `CCV_SECTIONS*CCV_W_CHWIDTH` | 8 | CCV_SECTIONS (arch); CCV_W_CHWIDTH (isa) |
| `operand_byp` | `CCV_SECTIONS*(CCV_L_OPERANDS_PER_LANE+1)*CCV_P_W_LANE_BYP_SEL` | 80 ⛔ | CCV_SECTIONS (arch); CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_P_W_LANE_BYP_SEL (tunable) |
| **total** | | **344** | ⛔ 276 preliminary |

### `ccv_ooe_miu_memop`

The memory operation itself: space, ordering, element width, CTA slot for bounds checking, and the displacement and scale enable the AGU needs (the shift is derived from chwidth). issue_mask is the issue group's lanes before the guard; the lanes that may access memory or fault are rcu_miu_addr.active_mask, which only RCU can compute. phys_dst and phys_pred are the write-back destinations (phys_pred is the uop's pred_dst, renamed), which MIU echoes on ccv_miu_rcu_data so RCU holds no table of outstanding loads. BULK DISCARD (A-41): mem_op 0xF discards every store of warp_id whose ROB index lies in the circular range (branch, tail]: rob_tag names the mispredicted branch and discard_tail, an overlay on disp, the warp's ROB tail, the youngest allocated entry inclusive. Every other field is reserved and zero. It is a command, not a memop: it gets no completion (A-53), the stores it discards still complete individually, and it is never sent in the same cycle as a memop of the same warp. mem_op, space and ordering arrive from DEC on ccv_dec_ooe_uop and pass through OOE unexamined (A-68); 0xF alone is OOE's own. mem_op 4 and 5 are a predicate transfer's uop (TI-36): MIU forms one address from lane 0, a load returns its word as pred_result, and a store completes at execute and drains after commit as a read-merge-write of its word, new = (old & ~m) | (d & m), m the address message's active_mask (MIU spec rev 25). SECTIONED (OI-33): pipes is the memop's footprint over MIU's pipes P0-P3, four at 32 bits, two at 16 and one at 8, at its data position; phys_dst is a row and dst_pos its position, echoed for the slice write-back. LOADS IN THE BULK DISCARD (AR's and OA's responses TI-21): the discard covers the warp's uncommitted loads in its range as well as its stores, each completed with status replay (ccv_miu_ooe_cmpl). A demotion's squash sends one for warp_id, whatever it holds, and drained waits only for the discarded loads' replay completions. A demotion's range is the whole ROB, branch == tail, which no other discard sends, since a mispredict's range is never empty. A discard of an empty ROB names no instruction and carries id class none; every memop carries instr, which MIU checks. LAUNCH-SLOT FORM (TI-31, AR's response; ISA O-45): slot_form set, the address is (window << 16) + (index << scale) + disp, where the window is the 32-bit word at launch_block_addr + 32 + 8 x arg_slot (ccv_rau_miu_cta). MIU keeps each CTA slot's sixteen windows in a table, filled a line at a time on first use: a memop whose window is not yet valid is an L1 miss, and completes as one. The table's valid bits clear on the slot's ccv_rau_miu_cta and on a kill; the windows are invariant within a launch (section 5.2, F-RO). F-RO, F-ADDR and F-ALIGN apply to the formed address as to any other. arg_slot is 4 bits, sixteen slots (OffArgs + 8k, k < 16). INTERLEAVED LOCAL FORM (IS-19, adopted by DA 2026-10-23; ISA v1.9 O-69): local_form set, disp is the unsigned byte offset b, and lane l's address is ((local_base + CCV_LANE_CONTEXTS) << 16) + (ctx << 22) + 128 x (b / 4) + 4l + b mod 4. local_base is the launch block's word at byte 24, which MIU's per-CTA table holds from the first line it already fills for the launch-slot form, on the same valid bit; ctx is the warp's hardware context, (CCV_P_CORE_ID << CCV_W_WARP_ID) | warp_id, which MIU forms itself, so no field carries it (OA's proposal IS-19). Word w of every lane's frame is one 128-byte line. A predicate transfer in this form (mem_op 4 or 5) is warp-scoped: its one address is the formula's with l = 0. base_per_lane is don't-care. F-ADDR, F-ALIGN and F-RO apply to the formed address. SIZED (O-80, DA tab rev 90; MIU spec rev 38): xfer_size and xfer_signed pass through from ccv_dec_ooe_uop. A nonzero xfer_size is the transfer, one byte (1) or two (2), and 0 leaves it at chwidth, rdata's width, as before. scale_en scales the index by the transfer size, and alignment (O-58) is the transfer's. A sized load's bytes are zero-extended, or sign-extended under xfer_signed, to chwidth before they leave on ccv_miu_rcu_data, which RCU writes at its dst_width as ever. A sized store moves rdata's low bytes.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `rs_idx` | `CCV_P_W_RS_IDX` | 6 ⚠️ | CCV_P_W_RS_IDX (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `dst_pos` | `CCV_W_PHYS_POS` | 2 | CCV_W_PHYS_POS (arch) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `pipes` | `CCV_MIU_PIPES` | 4 | CCV_MIU_PIPES (arch) |
| `disp` | `CCV_W_DISP` | 29 | CCV_W_DISP (isa) |
| `scale_en` | `1` | 1 | literal |
| `space` | `CCV_L_W_SPACE` | 1 | CCV_L_W_SPACE (isa) |
| `ordering` | `CCV_L_W_ORDERING` | 5 | CCV_L_W_ORDERING (isa) |
| `slot_form` | `1` | 1 | literal |
| `arg_slot` | `4` | 4 | literal |
| `local_form` | `1` | 1 | literal |
| `xfer_size` | `2` | 2 | literal |
| `xfer_signed` | `1` | 1 | literal |
| **total** | | **124** | ⛔ 4 preliminary, ⚠️ 30 provisional |

### `ccv_miu_spm_req`

Scratchpad access with a per-bank address set: one pass, at most one word in each bank, which bank_addr names, with write_data and byte_mask laid out by bank (bank b at bytes 4b to 4b + 3). MIU splits a warp's access into passes, one for each distinct word a bank holds for it, its lanes in ascending order, so a store's highest lane wins a word that lanes share, as ccv-sim's does. SPM's resolver issues one pass a cycle, and reports the cycles a pass waited for it as conflict_serialization (SPM spec rev 2; TI's rev 230). spm_op 0 reads and 1 writes, under byte_mask. byte_mask is already ANDed with the instruction's active_mask: a predicated-off lane's bytes are never enabled, so SPM needs no lane mask of its own (arch open A-20; an MIU assertion when MIU is RTL).

miu → spm · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_SPM` | 3 ⚠️ | CCV_P_W_REQ_MIU_SPM (provisional) |
| `bank_addr` | `CCV_SPM_BANKS*CCV_W_SPM_WORD` | 320 | CCV_SPM_BANKS (arch); CCV_W_SPM_WORD (arch) |
| `write_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `byte_mask` | `CCV_W_DATA/8` | 128 | CCV_W_DATA (isa) |
| `spm_op` | `CCV_L_W_SPM_OP` | 2 ⛔ | CCV_L_W_SPM_OP (preliminary, churn low) |
| **total** | | **1477** | ⛔ 2 preliminary, ⚠️ 3 provisional |

### `ccv_miu_dcu_req`

Cache access, physically addressed, with the exclusive-ownership request for atomics, and the store data with its byte mask.

miu → dcu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_DCU` | 4 ⚠️ | CCV_P_W_REQ_MIU_DCU (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | `CCV_W_ACCESS_SIZE` | 3 | CCV_W_ACCESS_SIZE (arch) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `exclusive_req` | `1` | 1 | literal |
| `write_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `byte_mask` | `CCV_W_DATA/8` | 128 | CCV_W_DATA (isa) |
| **total** | | **1212** | ⛔ 4 preliminary, ⚠️ 52 provisional |

### `ccv_dcu_mlc_req`

Fills and writebacks from L1 to the shared cache, tagged with core ID.

dcu → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_DCU_MLC` | 4 ⚠️ | CCV_P_W_REQ_DCU_MLC (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1082** | ⛔ 4 preliminary, ⚠️ 1076 provisional |

### `ccv_miu_fet_itlb`

Walker returning an ITLB entry.

miu → fet · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `itlb_refill` | `CCV_L_W_ITLB_ENTRY` | 64 ⛔ | CCV_L_W_ITLB_ENTRY (preliminary, churn low) |
| **total** | | **64** | ⛔ 64 preliminary |

### `ccv_fet_miu_itlb_req`

Fetch asking the walker for a translation on an ITLB miss: the virtual PAGE number (CCV_W_VA - CCV_L_PAGE_SHIFT bits), so no meaningless low bits can disagree with the TLB tag (arch open A-4).

fet → miu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `virtual_page` | `CCV_W_VA-CCV_L_PAGE_SHIFT` | 52 ⛔ | CCV_W_VA (arch); CCV_L_PAGE_SHIFT (preliminary, churn low) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| **total** | | **60** | ⛔ 52 preliminary |

### `ccv_mlc_exb_req`

The protocol-neutral outbound request. Everything the core knows about coherence is expressed here.

mlc → exb · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MLC_EXB` | 6 ⚠️ | CCV_P_W_REQ_MLC_EXB (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | `CCV_W_ACCESS_SIZE` | 3 | CCV_W_ACCESS_SIZE (arch) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `ownership_class` | `CCV_L_W_OWNERSHIP` | 3 ⛔ | CCV_L_W_OWNERSHIP (preliminary, churn med) |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1090** | ⛔ 7 preliminary, ⚠️ 1078 provisional |

### `ccv_exb_mlc_rsp`

Protocol-neutral inbound: fills and grants, matched to their request by req_id, and probes, which carry their line address and what they ask. probe_type is the discriminator: 0 is a response; non-zero is a probe, on which req_id, line_data, ownership_grant and miss are reserved and zero, so an overloaded field is checkable rather than 'meaningless' (arch open A-10).

exb → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MLC_EXB` | 6 ⚠️ | CCV_P_W_REQ_MLC_EXB (provisional) |
| `probe_type` | `CCV_L_W_PROBE_TYPE` | 2 ⛔ | CCV_L_W_PROBE_TYPE (preliminary, churn med) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership_grant` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1082** | ⛔ 2 preliminary, ⚠️ 1078 provisional |

### `ccv_exb_ext_out`

TileLink TL-C, outbound: channels A (acquire/get/put), C (release, probe response) and E (grant ack). The core is a master. How it decomposes -- flattened bundle or separate TL channels -- is EXB session work.

exb → EXTERNAL · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `tl_out` | `CCV_L_W_TL_OUT` | 1225 ⛔ | CCV_L_W_TL_OUT (preliminary, churn **HIGH**) |
| **total** | | **1225** | ⛔ 1225 preliminary |

### `ccv_rau_fet_launch`

A warp becoming resident: where to start, what code it may touch, which address space, which CTA slot. tier1_id is the tier-1 slot RAU placed the warp in (A-65): FET fetches it in that slot's binding group on ccv_fet_dec_instr and indexes its checkpoints by it, as OOE does from ccv_rau_ooe_alloc. live_mask (AR's response TI-27 (a)) is the warp's lanes, which FET picks among: lanes [0, n) with n = min(32, T - 32 x warp_in_cta), T the CTA's thread count from the grid descriptor (Q-50). A partial warp is always the low lanes (ISA section 5.3). 32 bits rather than a count, since a restore's mask on ccv_pca_fet_mig is arbitrary and FET loads one register from either.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `start_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `code_bounds` | `2*(CCV_W_VA-CCV_L_PAGE_SHIFT)` | 104 ⛔ | CCV_W_VA (arch); CCV_L_PAGE_SHIFT (preliminary, churn low) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `live_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **218** | ⛔ 104 preliminary, ⚠️ 3 provisional |

### `ccv_cru_rau_cfg`

Host-programmed policy (demotion threshold, progress threshold, launch enable) and the host's kill request with a grid selector. Both kill sources -- a fault from OOE, a request from the host -- land at RAU, the single issuer.

cru → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `demotion_threshold` | `CCV_W_CSR` | 32 | CCV_W_CSR (arch) |
| `progress_threshold` | `CCV_W_CSR` | 32 | CCV_W_CSR (arch) |
| `launch_enable` | `1` | 1 | literal |
| `kill_req` | `1` | 1 | literal |
| `kill_grid` | `CCV_L_W_GRID_SEL` | 8 ⛔ | CCV_L_W_GRID_SEL (preliminary, churn med) |
| **total** | | **74** | ⛔ 8 preliminary |

### `ccv_ext_exb_in`

TileLink TL-C, inbound: channels B (probe) and D (grant). Declared now rather than with a second core, because it is the only way the testbench memory can INITIATE a probe -- and so the only way to exercise the DCU probe port, probe as a wake source, and a probe arriving at a sleeping block before there is a second core to debug them with. A probe's line address and type ride in tl_in's TL-B fields; EXB turns them into ccv_exb_mlc_rsp's phys_addr and probe_type.

EXTERNAL → exb · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `tl_in` | `CCV_L_W_TL_IN` | 1176 ⛔ | CCV_L_W_TL_IN (preliminary, churn **HIGH**) |
| **total** | | **1176** | ⛔ 1176 preliminary |
