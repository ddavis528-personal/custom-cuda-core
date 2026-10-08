<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->

# Payload specification — all 48 channels

Every payload field has a width, so **every one of the 48
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
| All decided | 9 | 28 |
| ⚠️ Some provisional | 19 | 83 |
| ⛔ Some preliminary | 20 | 125 |
| **Total** | **48** | **236** |

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
| `CCV_P_W_SCHED_ATTR` | 16 | med | Width of sched_attr on ccv_dec_ooe_uop: the scheduling attributes DEC decodes so OOE never decodes opcode (A-66). Layout, MSB first: bypass_group (3: the codes of CCV_P_BYP_GROUPS; 0, don't-care, for an op that writes no result and reads no GPR, such as a branch or exit; OI-16, added 2026-10-08), rs_miu (1: the MIU reservation station), exec_rcu (1: RCU executes it, not a lane), cross_lane (1), writes_gpr (1), writes_pred (1), mem_kind (2: load, store, atomic, fence; meaningful with rs_miu), branch (1), serial (2: none, chwidth, barrier, exit; exit, TI-1: OOE holds it until every older uop of its warp completes and retires it as the warp's last), lat_class (3: 0 RCU, 1 lane, 2 L1-contracted load, 3 on completion, 4 SFU at CCV_LAT_SFU, 5 warp-collective at CCV_LAT_COLLECTIVE, 6-7 spare). mem_kind is don't-care unless rs_miu is set. A prefetch is mem_kind load with writes_gpr 0: it wakes nothing, so its latency class does not matter, and whether it may fault is MIU's semantics (A-68, confirmed 2026-10-03). SFU takes lat_class 4 and the warp-collective ops 5, with CCV_LAT_SFU and CCV_LAT_COLLECTIVE (Daniel's responses OA-4); a further fixed-latency unit takes 6 or 7, with its own latency parameter. Field set the OOE session's, bit order and codes the schema owner's; confirmed 2026-10-03. |

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

### MIU block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_MEM_OP` | 4 | med | Architectural memory operation: load, store, atomic family, prefetch, fence. Decoded by DEC and passed through OOE (A-68). Code 0xF is reserved for OOE's bulk discard (A-41): DEC never emits it. |

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

### OOE/MIU session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_SPACE` | 3 | low | Memory space: global, shared, const, local, with spare codes. |

### OOE/MIU session -- is scope a separate field?

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_ORDERING` | 4 | med | Two bits of order and two of scope. Whether scope is a separate field is the open part. |

### PCA session, from the parked-array organization

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_PCA_BANK` | 3 | med | Parked-context bank select: eight banks of four warps, from the proposed PCA organization. |

### RAU / CRU sessions

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_GRID_SEL` | 8 | med | Grid selector on the host's kill request (ccv_cru_rau_cfg). RAU maps grid to warp mask from tables it owns. Sized for 256 grid slots; the real number is how many grids RAU tracks at once. |

### RCU/LANE session -- see the src_arch vs operand mismatch

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_OPERANDS_PER_LANE` | 3 | **HIGH** | Operands shipped to a lane per beat. Whether a lane receives one instruction's operands or several, and whether the destination is read back for accumulate, both change this. |

### SPM block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_SPM_OP` | 2 | low | Scratchpad bank access: read, write, and room for a read-modify variant. |

### SYU session -- is the count biased?

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_BAR_COUNT` | 7 | low | Barrier entries in an allocated range. 7 bits expresses 1..64; 6 would do with a bias. Not stated by the payload pass, so the biasing choice is still open. |

### divergence model specification

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_PC_GROUPS` | 4 | **HIGH** | PCs carried in one migration, one per PC group. The real count depends on the divergence representation, which is unspecified. |

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

One lane's result, its predicate output (setp's compare, add.pp's predicate beside its GPR result), and its fault bit. RCU writes the PRF through per-lane write enables: every lane for an ordinary op (an inactive lane's result is its merge_data), only the inactive lanes for CCV_OP_PRF_COPY (A-44).

lane → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `result` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `pred_out` | `1` | 1 | literal |
| `lane_fault` | `1` | 1 | literal |
| **total** | | **34** | |

### `ccv_rau_ooe_alloc`

What RAU tells OOE about a warp's residency (A-64, A-65). alloc_op: 0 free, 1 launch, 2 restore-allocate, 3 restore-activate. Launch: OOE maps the warp's 16 architectural GPRs and 4 predicates to the hardwired zero registers (CCV_P_PHYS_ZERO, CCV_P_PRED_ZERO), so no zeroing traffic is sent and the warp may issue at once. Restore-allocate, before the PCA transfer: OOE allocates 16 GPRs and 4 predicates from the slot's reservation, so it never waits, and sends ccv_ooe_rcu_map with direction 1. Restore-activate, after ccv_pca_rau_mig_done: only now may the warp rename and issue. A single activation message would deadlock, since PCA's rows need the map and the map would need the activation. Free: the warp's state is released. tier1_id is the tier-1 slot RAU placed the warp in; OOE keeps its warp-to-slot table from it, which indexes the ROB, rob_tag's slot field, the per-slot reservations and the checkpoint-free bitmap, so ccv_dec_ooe_uop needs no slot field. Identity: ctaid and warp_in_cta, which OOE shadows so it can put srd's value in the immediate at issue (Q-38, A-25). RAU allocates no physical registers: OOE's global free lists do, from a reservation held per tier-1 slot whether occupied or not, so activation never waits and no credit is withheld (A-30, A-49). RAU's table is indexed by warp slot, which does not change while a warp parks, so identity stays out of the parked context by design.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `alloc_op` | `2` | 2 | literal |
| `ctaid` | `CCV_W_CTAID` | 32 | CCV_W_CTAID (isa) |
| `warp_in_cta` | `CCV_W_WARP_IN_CTA` | 5 | CCV_W_WARP_IN_CTA (isa) |
| **total** | | **46** | |

### `ccv_ooe_rau_status`

Per-warp stall and progress reporting, feeding demotion policy -- and fault_taken, the fault path to RAU: OOE raises it at retirement with the warp_id, and RAU maps warp to grid to mask from tables it owns. CRU records the fault in parallel (ccv_ooe_cru_fault) for the host, and is not on the path that stops execution.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `fault_taken` | `1` | 1 | literal |
| `stalled` | `1` | 1 | literal |
| `mlc_miss_seen` | `1` | 1 | literal |
| `retired_since_restore` | `CCV_W_RETIRED_CNT` | 8 | CCV_W_RETIRED_CNT (arch) |
| **total** | | **16** | |

### `ccv_rau_ooe_demote`

The order to squash a warp to its retirement boundary and report where to resume.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `squash_to_retirement` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_ooe_rau_drained`

Confirmation that only architectural state remains, with the resume PC. Migration may begin. OOE sends it only once the epoch notice it sent for the demotion (epoch_only on ccv_ooe_fet_redirect, A-74) has landed in FET, at its send cycle plus that channel's fixed latency, the same rule as its kill_ack. The guarantee that a restored warp is never fetched under an epoch older than OOE's (V-57) is then explicit rather than resting on the migration handshake's length.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `resume_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `arch_state_ready` | `1` | 1 | literal |
| **total** | | **70** | |

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

Architectural state back in on restore, one 1024-bit row per message in the same row numbering as ccv_rcu_pca_mig (0 to 15 GPRs, 16 and up predicate state), addressed by warp_id and mig_row so RCU writes it without state. The PC groups and their lane masks return to FET on ccv_pca_fet_mig.

pca → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `mig_row` | `CCV_W_MIG_ROW` | 5 | CCV_W_MIG_ROW (arch) |
| `row_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1034** | |

### `ccv_pca_rau_mig_done`

A migration has landed, either way. direction 0: a demotion, PCA holds every row from RCU and the PC groups from FET for warp_id, and RAU may reallocate the warp's slot. direction 1: a restore, PCA has sent every row to RCU and the PC groups to FET, and RAU may activate the warp. One ack from the block that sees both halves, rather than one from each sender (arch open A-3; the restore COMMAND is Q-39).

pca → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_syu_ooe_rel`

The set of warps a barrier released: one bit per warp context, tier-1 and parked (CCV_WARP_CONTEXTS), sized like kill_warp_mask and not by the lane count, which is 32 by coincidence (arch open A-12).

syu → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_mask_released` | `CCV_WARP_CONTEXTS` | 32 | CCV_WARP_CONTEXTS (arch) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| **total** | | **36** | |

## ⚠️ Carries a provisional width

### `ccv_fet_dec_instr`

Fetched, length-decoded, aligned instruction words, two per warp across all four tier-1 warps. Fetch faults ride here rather than a separate path. On a branch, checkpoint_id names the PC-group checkpoint FET took for it and pred_taken FET's predicted direction (uniform-only first; A-42); both are don't-care on other instructions. A predicted mask replaces pred_taken when divergent prediction lands. GROUP MASK AND EPOCH (A-69, A-70): group_mask is the lanes of the PC group the instruction was fetched for, set by FET, which owns the groups, and carried through DEC to OOE, which needs it at rename (merge elision: is the mask full?) and sends it as issue_mask. fetch_epoch is the warp's epoch when it was fetched: FET takes a new one from every redirect, and DEC and OOE drop any uop whose epoch is not the warp's current one, which is how wrong-path uops still in this channel, in DEC or in the decode queue are discarded after a redirect.

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
| **total** | | **160** | ⚠️ 5 provisional |

### `ccv_rcu_ooe_done`

Completion back to the ROB for arithmetic, with the faulting lane mask -- and branch resolution: the condition is a predicate, which lives in RCU's file, so RCU resolves. branch_mask (issue mask AND guard) is what makes a branch divergence rather than a jump; branch_taken is any lane taking it. CCV_OP_PRF_COPY produces no done: its masked load keeps one rob_tag and one completion, the load's (A-38). Nor does any memop: a load or store completes on ccv_miu_ooe_cmpl alone, and RCU, which sends its address and writes a load's data, sends nothing here for it (OI-4, Daniel 2026-10-08). A done for a memop would spend a transfer and, arriving late, could match a reused rob_tag.

rcu → ooe · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `exec_fault` | `1` | 1 | literal |
| `branch_taken` | `1` | 1 | literal |
| `branch_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `fault_lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **73** | ⚠️ 7 provisional |

### `ccv_rcu_miu_addr`

Address operands and store data for memory operations, and active_mask: issue mask AND guard predicate, computed by RCU, the one block holding both. The widest interface in the design.

rcu → miu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `active_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `base` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `index_per_lane` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `store_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **2151** | ⚠️ 7 provisional |

### `ccv_miu_rcu_data`

Load return data written into the register file. active_mask (echoing rcu_miu_addr's) gates the write: an inactive lane keeps its old value. pred_result carries a per-lane predicate the memory op produces (cas's success), for RCU's predicate file. phys_dst and phys_pred echo the memop's, so RCU writes back without state: load_data to phys_dst, pred_result (cas's success) to phys_pred. pred_we, set by MIU from the op (cas, not a load), says whether pred_result is written at all -- without it a stateless RCU would clobber the predicate phys_pred names on every load. An L1 hit's data lands at the contracted cycle, with its completion (A-47). A masked load's inactive lanes are written by its copy-only op through a lane, never by MIU, so this channel carries no merge fields (A-33).

miu → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `active_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `pred_result` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_we` | `1` | 1 | literal |
| `load_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1110** | ⚠️ 21 provisional |

### `ccv_miu_ooe_cmpl`

Completion, replay, fault and MLC miss. The miss indication is the primary demotion trigger, which is why it rides the completion path rather than its own channel. Every memop MIU accepts gets exactly one completion, including a store later bulk-discarded; the bulk-discard command itself gets none (A-41, A-53). An L1 hit completes at exactly CCV_LAT_L1_HIT; no completion at that cycle is the miss indication. Past L1 nothing is contracted, and scratchpad loads and atomics never wake dependants speculatively (A-46).

miu → ooe · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `status` | `CCV_W_STATUS` | 2 | CCV_W_STATUS (arch) |
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `address` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `mlc_miss` | `1` | 1 | literal |
| **total** | | **110** | ⚠️ 7 provisional |

### `ccv_ooe_miu_retire`

Commit or discard for the store buffer, so stores leave only after their instruction retires.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `commit_or_discard` | `1` | 1 | literal |
| **total** | | **8** | ⚠️ 7 provisional |

### `ccv_ooe_fet_redirect`

A mispredicted branch: the warp, its tier-1 stream, the branch's checkpoint, the lanes that took it, the target PC, and a fetch epoch so FET can discard in-flight fetches from the wrong path. RCU resolves (the condition is a predicate) and OOE compares the outcome with the prediction (pred_taken, A-42); OOE redirects only on a mispredict, at rate 1, serialising them deliberately (A-6). FET owns the PC-group state: it holds a checkpoint of it per unresolved branch (CCV_P_BR_CKPTS) and rebuilds the groups itself from checkpoint_id plus taken_mask, so OOE no longer resends group masks it does not own. Fixed latency (A-58): FET applies a redirect the cycle it lands and never stalls it, because ccv_ooe_fet_ckpt_free is latency-matched to this channel and the pair's arrival order must be its send order; FET applies a redirect before any free landing the same cycle. EPOCH OWNERSHIP (A-70, A-74): OOE owns every warp's fetch epoch and is the only block that advances it: on each redirect, on ccv_rau_ooe_demote, and on a kill. It tells FET of every change on this channel. A redirect carries the new epoch; a demotion or kill sends an epoch notice, epoch_only = 1, for which FET only takes fetch_epoch for warp_id, and checkpoint_id, taken_mask and target_pc are don't-care (no restore, no PC change, no checkpoint freed). FET advances nothing itself. It tags everything it fetches for the warp afterwards with that epoch on ccv_fet_dec_instr. Both blocks hold the epoch per warp_id, not per tier-1 slot, so it survives demotion and restore. Neither resets it at launch, because a relaunched warp_id could meet its predecessor's uops still in flight. The channel is fixed-latency and in order, so notices and redirects for a warp land in the order sent, and V-56 holds: one channel latency after every change, FET's epoch for a warp equals OOE's.

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
| **total** | | **109** | ⚠️ 5 provisional |

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

### `ccv_ooe_rcu_map`

Where a migrating warp's architectural registers live: its RAT, 16 physical GPR names and 4 physical predicate names. Physical locations exist only in OOE's RAT, so this replaces RAU's prf_base + arch addressing. direction 0: demote, RCU reads the named rows out to PCA; 1: restore, RCU writes PCA's rows into them. RCU pairs it with ccv_rau_rcu_mig by warp and direction (A-45), and ccv_ooe_rau_drained is sent only after it. Rate 1, separate from the rate-4 issue channel that binds the machine's width. A message is one whole map, atomic and ordered by construction on a single slot, so no slot attributes are declared (the schema refuses them on a rate-1 channel). A demotion map may name the zero registers (A-64): RCU then reads zeros out to PCA. A restore map never does: restore-allocate allocates every register it names.

ooe → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `gpr_map` | `CCV_GPRS*CCV_P_W_PHYS_REG` | 128 ⚠️ | CCV_GPRS (isa); CCV_P_W_PHYS_REG (provisional) |
| `pred_map` | `CCV_PREDS*CCV_P_W_PHYS_PRED` | 24 ⚠️ | CCV_PREDS (isa_provisional); CCV_P_W_PHYS_PRED (provisional) |
| **total** | | **158** | ⚠️ 152 provisional |

### `ccv_rau_miu_cta`

Per-CTA scratchpad bounds and the launch block address, so MIU can check F-SHARED and service launch-block reads.

rau → miu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `spm_base` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `spm_limit` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `launch_block_addr` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| **total** | | **101** | ⚠️ 3 provisional |

### `ccv_ooe_syu_bar`

Barrier arrive and wait. A warp may be demoted while waiting, so the barrier table tracks non-resident warps.

ooe → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| `arrive_or_wait` | `1` | 1 | literal |
| **total** | | **13** | ⚠️ 3 provisional |

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

## ⛔ Carries a preliminary width

### `ccv_dec_ooe_uop`

Format-decoded operations with architectural register names (src_arch holds two sources and src2_arch the third -- Format A's rs2, an independent source such as mad.lo's and dp4's accumulator input; dst_arch is the destination, always), the predicate guard and the predicate destination as separate fields (pred_guard with pred_neg, pred_dst with pred_we: ISA Format C carries them in separate fields, so @P0 setp P1 is one instruction), the immediate and scale enable, six per cycle into the queue ahead of rename. imm is always the architectural immediate: a branch's is its encoded halfword offset from the next instruction, and ilen (the instruction length code, as on ccv_fet_dec_instr) rides beside it, so OOE computes the target as pc + bytes(ilen) + 2 * imm rather than DEC folding the length in (arch open A-8). checkpoint_id and pred_taken pass through from FET on a branch: OOE compares RCU's resolved outcome with pred_taken to detect a mispredict, then names the checkpoint on ccv_ooe_fet_redirect (A-42). sched_attr (A-66): the scheduling attributes, decoded by DEC so OOE never decodes opcode, whose encoding is preliminary and expected to churn. The three fields A-75 asked for (TI-1, agreed by Daniel 2026-10-08), so OOE never decodes opcode: src_valid[3], bit i set when source i is a real read (bits 0 and 1 the two fields of src_arch, bit 2 src2_arch), so OOE renames and waits on nothing else; pred_use[2], how the predicate is read: 0 none, 1 guard (an enable: switched-off lanes keep their old value, so merge_en is set, and a masked load owes its copy), 2 data (sel's selector: no merge); imm_kind[2], what imm holds: 0 a literal, 1 predicate logic's two sources (qualifiers in imm[5:0], [2:0] and [5:3], each [1:0] the architectural predicate and [2] its negate), which OOE renames and rewrites on ccv_ooe_rcu_issue, 2 srd's warp_base identity, 3 srd's ctaid identity, which OOE substitutes. Exit is sched_attr's serial code 3. A guard or data use is never bypassed, and OA adds that pred_use feeds the A-62 late bit. Layout MSB first: bypass_group[3], rs_miu, exec_rcu, cross_lane, writes_gpr, writes_pred, mem_kind[2], branch, serial[2], lat_class[3] (CCV_P_W_SCHED_ATTR has the codes). lat_class sets a producer's full latency; bypass_group, as producer and as consumer, indexes the bypass table, whose penalties are parameters (OI-16, Daniel's responses OA-4). DEC owns the opcode-to-attribute table. mem_op, space and ordering (A-68) are decoded here too, for memory ops, and OOE copies them to ccv_ooe_miu_memop unexamined, so opcode decoding lives only in DEC and MIU stays off the opcode census. DEC never emits mem_op 0xF, which is OOE's bulk discard (A-41); asserted on DEC's output (V-52). All three are don't-care unless sched_attr's rs_miu is set, as is mem_kind. group_mask and fetch_epoch pass through from FET (A-69, A-70): OOE renames no uop whose fetch_epoch differs from its warp's current epoch, and every issued uop's issue_mask is the group_mask it arrived with. The mask rides per slot. Sharing it once per warp was considered and dropped (A-72): it saves about 10% of ccv_fet_dec_instr's wires and at most 5% of this channel's, and here it would also need the freely bound slots regrouped by warp and a field shared across a slot group.

dec → ooe · rate 6 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `group_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `fetch_epoch` | `CCV_P_W_FETCH_EPOCH` | 3 ⚠️ | CCV_P_W_FETCH_EPOCH (provisional) |
| `uop_class` | `CCV_L_W_CLASS` | 3 ⛔ | CCV_L_W_CLASS (preliminary, churn low) |
| `sched_attr` | `CCV_P_W_SCHED_ATTR` | 16 ⛔ | CCV_P_W_SCHED_ATTR (preliminary, churn med) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `space` | `CCV_L_W_SPACE` | 3 ⛔ | CCV_L_W_SPACE (preliminary, churn low) |
| `ordering` | `CCV_L_W_ORDERING` | 4 ⛔ | CCV_L_W_ORDERING (preliminary, churn med) |
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
| `imm_kind` | `2` | 2 | literal |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `ilen` | `CCV_W_ILEN` | 2 | CCV_W_ILEN (isa) |
| `checkpoint_id` | `CCV_P_W_CKPT_ID` | 2 ⚠️ | CCV_P_W_CKPT_ID (provisional) |
| `pred_taken` | `1` | 1 | literal |
| `scale_en` | `1` | 1 | literal |
| `decode_fault` | `1` | 1 | literal |
| **total** | | **211** | ⛔ 39 preliminary, ⚠️ 37 provisional |

### `ccv_ooe_rcu_issue`

What the scheduler selected: physical register names (three sources; the guard predicate and the predicate destination separately, with pred_we saying whether a predicate is written), opcode, element width, the issue group's lane mask, and the ALU immediate, which RCU substitutes into an operand slot at register read so lanes never see an immediate. Four per cycle, the binding width of the machine. MERGE (A-33): with merge_en set (the issue mask is not full or the op is guarded), phys_old_dst is a fourth source, read at issue with the others and carried to the lane as merge_data, so it bypasses like any operand; the lane writes its inactive lanes from it. merge_en = 0 makes phys_old_dst don't-care. Predicates merge in RCU instead: at write-back RCU read-modify-writes the 32-bit row from phys_pred_old_dst (A-43). A masked load sends a second, copy-only op here, opcode CCV_OP_PRF_COPY = 0x1FF, with the load's rob_tag: it writes only the load's inactive lanes (GPR and predicate destination alike) and produces no done (A-38). Fixed latency: once RCU accepts an issue the result lands at the contracted latency, and there is no port grant (Q-51, A-28). ZERO REGISTERS (A-64): CCV_P_PHYS_ZERO and CCV_P_PRED_ZERO, one past each pool, read zero and are never written. A read of one needs no PRF port: RCU decodes the index and drives a constant, which matters because a launched warp's early reads all name them (A-73). A launched warp's sources, guard and old destinations may name them; phys_dst, phys_pred_dst and the destinations of every write never do. PREDICATE LOGIC (TI-1): pand, por and pxor read two predicates, and OOE renames them like any source, so imm carries their physical names, not DEC's qualifiers: [CCV_P_W_PHYS_PRED-1:0] the first source, [CCV_P_W_PHYS_PRED] its negate, then the second source and its negate, 2 (CCV_P_W_PHYS_PRED + 1) = 14 bits. RCU reads them as it reads phys_pred_guard, so the issue channel does not grow.

ooe → rcu · rate 4 · execution

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
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `dispatch_fault` | `1` | 1 | literal |
| **total** | | **149** | ⛔ 9 preliminary, ⚠️ 97 provisional |

### `ccv_rcu_lane_ops`

Operands and control to one lane. pred_bit is the lane's ENABLE: issue mask AND guard, the same computation as active_mask. A lane with pred_bit clear does not compute: it returns merge_data as its result, which is how a masked or guarded write keeps its inactive lanes' old values under rename (A-33, A-44); merge_data is don't-care when the op's merge_en is 0, since then every lane is enabled. For CCV_OP_PRF_COPY an enabled lane's result is don't-care: RCU writes only the inactive lanes. pred_data is a predicate read as DATA, e.g. sel's selector, which chooses between sources on every enabled lane. Section enables gate the narrow sub-datapaths and the SFU. What reaches a lane: every opcode with a per-lane input, a GPR or the lane's own hardwired index (Q-32, Q-38). RCU executes the opcodes whose inputs are all warp-level -- predicate logic (pand/por/pxor), pmov, movi, movi48, branch resolution -- plus the horizontal ops (shfl, vote, ballot, unballot). setp, add.pp and cas run in lanes although they write predicates; pred_out and pred_result carry those back. srd runs in the lane: selector 0 ORs the lane's index into the warp_base immediate, selector 1 passes %ctaid through, and the two arrive as different opcodes, decoded from the selector by DEC. operand_byp is the lane-local bypass (A-59, TI-8): one CCV_P_W_LANE_BYP_SEL select per operand slot and a last one for merge_data. A select with its forward bit set replaces the value RCU read with a result this lane computed earlier, named by the producer's issue slot and its age, the cycles between the two ops' arrival here less CCV_LAT_LANE_BYP. RCU sets it for a source whose lane producer has not yet written the PRF, which only a dependant woken at the bypass offset can meet; a lane never forwards a result younger than CCV_LAT_LANE_BYP. The select is the same on every lane, like opcode.

rcu → lane · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `operand` | `CCV_L_OPERANDS_PER_LANE*CCV_W_LANE_DATA` | 96 ⛔ | CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_LANE_DATA (isa) |
| `merge_data` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `pred_bit` | `1` | 1 | literal |
| `pred_data` | `1` | 1 | literal |
| `section_en` | `4` | 4 | literal |
| `operand_byp` | `(CCV_L_OPERANDS_PER_LANE+1)*CCV_P_W_LANE_BYP_SEL` | 20 ⛔ | CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_P_W_LANE_BYP_SEL (tunable) |
| **total** | | **163** | ⛔ 125 preliminary |

### `ccv_ooe_miu_memop`

The memory operation itself: space, ordering, element width, CTA slot for bounds checking, and the displacement and scale enable the AGU needs (the shift is derived from chwidth). issue_mask is the issue group's lanes before the guard; the lanes that may access memory or fault are rcu_miu_addr.active_mask, which only RCU can compute. phys_dst and phys_pred are the write-back destinations (phys_pred is the uop's pred_dst, renamed), which MIU echoes on ccv_miu_rcu_data so RCU holds no table of outstanding loads. BULK DISCARD (A-41): mem_op 0xF discards every store of warp_id whose ROB index lies in the circular range (branch, tail]: rob_tag names the mispredicted branch and discard_tail, an overlay on disp, the warp's ROB tail, the youngest allocated entry inclusive. Every other field is reserved and zero. It is a command, not a memop: it gets no completion (A-53), the stores it discards still complete individually, and it is never sent in the same cycle as a memop of the same warp. mem_op, space and ordering arrive from DEC on ccv_dec_ooe_uop and pass through OOE unexamined (A-68); 0xF alone is OOE's own.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 6 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `disp` | `CCV_W_DISP` | 16 | CCV_W_DISP (isa) |
| `scale_en` | `1` | 1 | literal |
| `space` | `CCV_L_W_SPACE` | 3 ⛔ | CCV_L_W_SPACE (preliminary, churn low) |
| `ordering` | `CCV_L_W_ORDERING` | 4 ⛔ | CCV_L_W_ORDERING (preliminary, churn med) |
| **total** | | **91** | ⛔ 11 preliminary, ⚠️ 24 provisional |

### `ccv_miu_spm_req`

Scratchpad access with a per-bank address set. Bank conflicts resolve inside SPM. byte_mask is already ANDed with the instruction's active_mask: a predicated-off lane's bytes are never enabled, so SPM needs no lane mask of its own (arch open A-20; an MIU assertion when MIU is RTL).

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

A warp becoming resident: where to start, what code it may touch, which address space, which CTA slot. tier1_id is the tier-1 slot RAU placed the warp in (A-65): FET fetches it in that slot's binding group on ccv_fet_dec_instr and indexes its checkpoints by it, as OOE does from ccv_rau_ooe_alloc.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `start_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `code_bounds` | `2*(CCV_W_VA-CCV_L_PAGE_SHIFT)` | 104 ⛔ | CCV_W_VA (arch); CCV_L_PAGE_SHIFT (preliminary, churn low) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| **total** | | **186** | ⛔ 104 preliminary, ⚠️ 3 provisional |

### `ccv_rau_rcu_mig`

Which warp and direction a migration moves, and which parked bank it targets. RCU pairs it with ccv_ooe_rcu_map by warp_id and direction and proceeds once both have arrived, in either order; at most one migration per warp is in flight (A-45).

rau → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `bank_select` | `CCV_L_W_PCA_BANK` | 3 ⛔ | CCV_L_W_PCA_BANK (preliminary, churn med) |
| **total** | | **9** | ⛔ 3 preliminary |

### `ccv_fet_pca_mig`

A demoted warp's PC groups, out to the parked array: each group's PC and its lane mask, which together are the warp's divergence state in FET (the groups FET maintains, and rebuilds from checkpoint_id and taken_mask on a redirect; A-2, A-36). FET owns the PC and its update logic, so the group PCs migrate from FET directly -- not through RCU, which would cross two blocks and hold state it has no other reason to touch. RAU sequences this and the RCU->PCA transfer; PCA acks both halves at once on ccv_pca_rau_mig_done. Checkpoints never migrate: demotion squashes to the retirement boundary, so a demoted warp has no unresolved branch.

fet → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| `group_masks` | `CCV_L_PC_GROUPS*CCV_W_LANE_MASK` | 128 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_LANE_MASK (isa) |
| **total** | | **389** | ⛔ 384 preliminary |

### `ccv_pca_fet_mig`

A restored warp's PC groups, PCs and lane masks, back to FET, which resumes fetch from them.

pca → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| `group_masks` | `CCV_L_PC_GROUPS*CCV_W_LANE_MASK` | 128 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_LANE_MASK (isa) |
| **total** | | **389** | ⛔ 384 preliminary |

### `ccv_rau_fet_mig`

The migration command to FET, the same command ccv_rau_rcu_mig gives RCU: which warp, which direction, which parked bank. On demotion FET sends the warp's PC groups on ccv_fet_pca_mig. RAU sequences both halves of a migration, so both halves need the command. tier1_id is the warp's tier-1 slot (A-65): on a restore, the slot RAU is placing it in, which FET needs before PCA's PC groups arrive; on a demotion, the slot being vacated.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `direction` | `1` | 1 | literal |
| `bank_select` | `CCV_L_W_PCA_BANK` | 3 ⛔ | CCV_L_W_PCA_BANK (preliminary, churn med) |
| **total** | | **11** | ⛔ 3 preliminary |

### `ccv_rau_syu_alloc`

Barrier entries allocated to or freed from a CTA slot.

rau → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_base` | `CCV_W_BAR_ENTRY` | 6 | CCV_W_BAR_ENTRY (arch) |
| `barrier_count` | `CCV_L_W_BAR_COUNT` | 7 ⛔ | CCV_L_W_BAR_COUNT (preliminary, churn low) |
| `allocate_or_free` | `1` | 1 | literal |
| **total** | | **17** | ⛔ 7 preliminary, ⚠️ 3 provisional |

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
