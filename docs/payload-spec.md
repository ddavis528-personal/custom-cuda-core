<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->

# Payload specification — all 46 channels

Every payload field has a width, so **every one of the 46
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
| All decided | 8 | 24 |
| ⚠️ Some provisional | 15 | 61 |
| ⛔ Some preliminary | 23 | 121 |
| **Total** | **46** | **206** |

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

### EXB session -- flattened bundle or separate TL channels

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_TL_IN` | 1176 | **HIGH** | TL-C inbound, B + D plus a valid bit per TL channel: B 641 (as A), D 533 (opcode 3, param 2, size 4, source 6, sink 4, denied 1, data 512, corrupt 1), valids 2. The earlier single 1760 reproduces exactly as A + C + D + E + 5 valids -- it never included B, the probe. |
| `CCV_L_W_TL_OUT` | 1225 | **HIGH** | TL-C outbound, A + C + E plus a valid bit per TL channel, at 512-bit beat, 48-bit address, 6-bit source, 4-bit sink: A 641 (opcode 3, param 3, size 4, source 6, address 48, mask 64, data 512, corrupt 1), C 577 (A without mask), E 4 (sink), valids 3. |

### ISA opcode census, then DEC/OOE/RCU agree the hops

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_OPCODE` | 9 | **HIGH** | One encoding across all three hops, owned by the schema (Q-34): a block may narrow it locally only as a strict projection, never a re-encoding. Narrowing at RCU->LANE is likely, but the ISA opcode census sets it. Anything decoding this field will be rewritten. |

### MIU block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_MEM_OP` | 4 | med | Architectural memory operation: load, store, atomic family, prefetch, fence. |

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

### RAU/OOE session -- register or chunk granularity

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_PRF_BASE` | 8 | med | Physical register window base, at REGISTER granularity. Chunked allocation would narrow this and prf_size together -- one decision for the pair. |

### RAU/OOE session, with CCV_L_W_PRF_BASE

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_PRF_SIZE` | 8 | med | Physical register window size. Same granularity decision as CCV_L_W_PRF_BASE. |

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
| `CCV_L_W_PRED_STATE` | 1024 | **HIGH** | Predicate registers plus a reconvergence stack of eight entries of mask and PC. THE most likely field to be underestimated: the divergence model is stored here and has never been specified. |

## Open questions that no width can close

Each is numbered in [`open-items.md`](open-items.md), the one list of what is undecided.

### Q-18 — rcu miu width

*partitioning question that a width exposed — partitioning / floorplan*

ccv_rcu_miu_addr carries index_per_lane (1024) beside store_data (1024) at rate 4 -- roughly 8,400 wires from RCU into MIU, almost certainly the widest interface in the design. It argues for co-locating the AGUs with RCU, or moving address generation into the register read stage.

**Blocks:** Nothing today -- the skeleton does not care how wide a bus is. Settle before floorplan rather than after, since the answer may move a block boundary and block boundaries are swap boundaries.

---

## Every channel

## All widths decided

### `ccv_fet_dec_instr`

Fetched, length-decoded, aligned instruction words, two per warp across all four tier-1 warps. Fetch faults ride here rather than a separate path.

fet → dec · rate 8 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `instr` | `CCV_W_INSTR` | 48 | CCV_W_INSTR (isa) |
| `length` | `CCV_W_ILEN` | 2 | CCV_W_ILEN (isa) |
| `fetch_fault` | `1` | 1 | literal |
| **total** | | **122** | |

### `ccv_lane_rcu_res`

One lane's result, its predicate output (setp's compare, add.pp's predicate beside its GPR result), and its fault bit.

lane → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `result` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `pred_out` | `1` | 1 | literal |
| `lane_fault` | `1` | 1 | literal |
| **total** | | **34** | |

### `ccv_fet_miu_itlb_req`

Fetch asking the walker for a translation on an ITLB miss.

fet → miu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `virtual_page` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| **total** | | **72** | |

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

Confirmation that only architectural state remains, with the resume PC. Migration may begin.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `resume_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `arch_state_ready` | `1` | 1 | literal |
| **total** | | **70** | |

### `ccv_pca_rau_mig_done`

A demotion has landed: PCA holds every GPR row from RCU and the PC groups from FET for warp_id. RAU waits for this before reallocating the warp's slot. One ack from the block that sees both halves arrive, rather than one from each sender.

pca → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| **total** | | **5** | |

### `ccv_syu_ooe_rel`

The set of warps a barrier released.

syu → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_mask_released` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| **total** | | **36** | |

## ⚠️ Carries a provisional width

### `ccv_rcu_ooe_done`

Completion back to the ROB for arithmetic, with the faulting lane mask -- and branch resolution: the condition is a predicate, which lives in RCU's file, so RCU resolves. branch_mask (issue mask AND guard) is what makes a branch divergence rather than a jump; branch_taken is any lane taking it.

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

Load return data written into the register file. active_mask (echoing rcu_miu_addr's) gates the write: an inactive lane keeps its old value. pred_result carries a per-lane predicate the memory op produces (cas's success), for RCU's predicate file. phys_dst and phys_pred echo the memop's, so RCU writes back without state: load_data to phys_dst, pred_result (cas's success) to phys_pred. pred_we, set by MIU from the op (cas, not a load), says whether pred_result is written at all -- without it a stateless RCU would clobber the predicate phys_pred names on every load.

miu → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `active_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `pred_result` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 8 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_we` | `1` | 1 | literal |
| `load_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1112** | ⚠️ 23 provisional |

### `ccv_miu_ooe_cmpl`

Completion, replay, fault and MLC miss. The miss indication is the primary demotion trigger, which is why it rides the completion path rather than its own channel.

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

Cache read data, hit indication and whether ownership was granted.

dcu → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_MIU_DCU` | 4 ⚠️ | CCV_P_W_REQ_MIU_DCU (provisional) |
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `hit` | `1` | 1 | literal |
| `ownership_granted` | `1` | 1 | literal |
| **total** | | **1030** | ⚠️ 4 provisional |

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

Instruction cache miss straight to MLC, bypassing the D-cache.

fet → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_FET_MLC` | 2 ⚠️ | CCV_P_W_REQ_FET_MLC (provisional) |
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| **total** | | **58** | ⚠️ 50 provisional |

### `ccv_mlc_fet_ifill_rsp`

Instruction line fill.

mlc → fet · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `req_id` | `CCV_P_W_REQ_FET_MLC` | 2 ⚠️ | CCV_P_W_REQ_FET_MLC (provisional) |
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1026** | ⚠️ 1026 provisional |

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

Format-decoded operations with architectural register names (src_arch holds two sources and src2_arch the third -- Format A's rs2, an independent source such as mad.lo's and dp4's accumulator input; dst_arch is the destination, always), the predicate guard and the predicate destination as separate fields (pred_guard with pred_neg, pred_dst with pred_we: ISA Format C carries them in separate fields, so @P0 setp P1 is one instruction), the immediate and scale enable, six per cycle into the queue ahead of rename.

dec → ooe · rate 6 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `uop_class` | `CCV_L_W_CLASS` | 3 ⛔ | CCV_L_W_CLASS (preliminary, churn low) |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `src_arch` | `2*CCV_W_ARCH_REG` | 8 | CCV_W_ARCH_REG (isa) |
| `src2_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `dst_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `pred_guard` | `CCV_W_ARCH_PRED` | 2 | CCV_W_ARCH_PRED (isa) |
| `pred_neg` | `1` | 1 | literal |
| `pred_dst` | `CCV_W_ARCH_PRED` | 2 | CCV_W_ARCH_PRED (isa) |
| `pred_we` | `1` | 1 | literal |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `scale_en` | `1` | 1 | literal |
| `decode_fault` | `1` | 1 | literal |
| **total** | | **137** | ⛔ 12 preliminary, ⚠️ 32 provisional |

### `ccv_ooe_rcu_issue`

What the scheduler selected: physical register names (three sources; the guard predicate and the predicate destination separately, with pred_we saying whether a predicate is written), opcode, element width, the issue group's lane mask, and the ALU immediate, which RCU substitutes into an operand slot at register read so lanes never see an immediate. Four per cycle, the binding width of the machine.

ooe → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `phys_src` | `2*CCV_P_W_PHYS_REG` | 16 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_src2` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred_guard` | `CCV_P_W_PHYS_PRED` | 8 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_neg` | `1` | 1 | literal |
| `phys_pred_dst` | `CCV_P_W_PHYS_PRED` | 8 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `pred_we` | `1` | 1 | literal |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `dispatch_fault` | `1` | 1 | literal |
| **total** | | **138** | ⛔ 9 preliminary, ⚠️ 87 provisional |

### `ccv_rcu_lane_ops`

Operands and control to one lane. pred_bit is the lane's ENABLE: issue mask AND guard, the same computation as active_mask, so a lane with pred_bit clear does nothing. pred_data is a predicate read as DATA, e.g. sel's selector, which chooses between sources on every enabled lane. Section enables gate the narrow sub-datapaths and the SFU. What reaches a lane: every opcode with a per-lane input, a GPR or the lane's own hardwired index (Q-32, Q-38). RCU executes the opcodes whose inputs are all warp-level -- predicate logic (pand/por/pxor), pmov, movi, movi48, branch resolution -- plus the horizontal ops (shfl, vote, ballot, unballot). setp, add.pp and cas run in lanes although they write predicates; pred_out and pred_result carry those back. srd runs in the lane: selector 0 ORs the lane's index into the warp_base immediate, selector 1 passes %ctaid through, and the two arrive as different opcodes, decoded from the selector by DEC.

rcu → lane · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `operand` | `CCV_L_OPERANDS_PER_LANE*CCV_W_LANE_DATA` | 96 ⛔ | CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_LANE_DATA (isa) |
| `pred_bit` | `1` | 1 | literal |
| `pred_data` | `1` | 1 | literal |
| `section_en` | `4` | 4 | literal |
| **total** | | **111** | ⛔ 105 preliminary |

### `ccv_ooe_miu_memop`

The memory operation itself: space, ordering, element width, CTA slot for bounds checking, and the displacement and scale enable the AGU needs (the shift is derived from chwidth). issue_mask is the issue group's lanes before the guard; the lanes that may access memory or fault are rcu_miu_addr.active_mask, which only RCU can compute. phys_dst and phys_pred are the write-back destinations (phys_pred is the uop's pred_dst, renamed), which MIU echoes on ccv_miu_rcu_data so RCU holds no table of outstanding loads.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 8 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `issue_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `disp` | `CCV_W_DISP` | 16 | CCV_W_DISP (isa) |
| `scale_en` | `1` | 1 | literal |
| `space` | `CCV_L_W_SPACE` | 3 ⛔ | CCV_L_W_SPACE (preliminary, churn low) |
| `ordering` | `CCV_L_W_ORDERING` | 4 ⛔ | CCV_L_W_ORDERING (preliminary, churn med) |
| **total** | | **93** | ⛔ 11 preliminary, ⚠️ 26 provisional |

### `ccv_ooe_fet_redirect`

A resolved branch that changes fetch: the warp, its tier-1 stream, the target PC, the updated PC-group lane masks, and a fetch epoch so FET can discard in-flight fetches from the wrong path. RCU resolves (the condition is a predicate); OOE redirects. FET owns the PC and its update logic, so the divergent PC-group state lives in FET.

ooe → fet · rate 1 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `tier1_id` | `CCV_W_TIER1_ID` | 2 | CCV_W_TIER1_ID (arch) |
| `target_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `group_masks` | `CCV_L_PC_GROUPS*CCV_W_LANE_MASK` | 128 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_LANE_MASK (isa) |
| `fetch_epoch` | `CCV_P_W_FETCH_EPOCH` | 2 ⚠️ | CCV_P_W_FETCH_EPOCH (provisional) |
| **total** | | **201** | ⛔ 128 preliminary, ⚠️ 2 provisional |

### `ccv_miu_spm_req`

Scratchpad access with a per-bank address set. Bank conflicts resolve inside SPM.

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

Protocol-neutral inbound: fills and grants, matched to their request by req_id, and probes, which carry their line address and what they ask (probe_type != 0; req_id is then meaningless).

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

A warp becoming resident: where to start, what code it may touch, which address space, which CTA slot.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `start_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `code_bounds` | `2*(CCV_W_VA-CCV_L_PAGE_SHIFT)` | 104 ⛔ | CCV_W_VA (arch); CCV_L_PAGE_SHIFT (preliminary, churn low) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| **total** | | **184** | ⛔ 104 preliminary, ⚠️ 3 provisional |

### `ccv_rau_ooe_alloc`

The warp's physical register window, activated or freed, and its identity: ctaid and warp_in_cta, which OOE shadows so it can put srd's value in the immediate at issue (Q-38). Promotion re-sends this message, so identity arrives with every activation. RAU's table is indexed by warp slot, which does not change while a warp parks, so identity stays out of the parked context by design.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `prf_base` | `CCV_L_W_PRF_BASE` | 8 ⛔ | CCV_L_W_PRF_BASE (preliminary, churn med) |
| `prf_size` | `CCV_L_W_PRF_SIZE` | 8 ⛔ | CCV_L_W_PRF_SIZE (preliminary, churn med) |
| `activate_or_free` | `1` | 1 | literal |
| `ctaid` | `CCV_W_CTAID` | 32 | CCV_W_CTAID (isa) |
| `warp_in_cta` | `CCV_W_WARP_IN_CTA` | 5 | CCV_W_WARP_IN_CTA (isa) |
| **total** | | **59** | ⛔ 16 preliminary |

### `ccv_rau_rcu_mig`

Which warp and direction a migration moves, and which parked bank it targets.

rau → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `bank_select` | `CCV_L_W_PCA_BANK` | 3 ⛔ | CCV_L_W_PCA_BANK (preliminary, churn med) |
| **total** | | **9** | ⛔ 3 preliminary |

### `ccv_rcu_pca_mig`

Architectural register and predicate state out to the parked array on demotion, one GPR row per message. Addressed: warp_id and row_idx say where the row goes, so PCA places it from the data itself rather than inferring placement from a command it never sees (the RAU->RCU command is RCU's). The PC groups are not here: FET owns them, and they travel on ccv_fet_pca_mig.

rcu → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `row_idx` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | `CCV_L_W_PRED_STATE` | 1024 ⛔ | CCV_L_W_PRED_STATE (preliminary, churn **HIGH**) |
| **total** | | **2057** | ⛔ 1024 preliminary |

### `ccv_pca_rcu_mig`

Architectural register and predicate state back in on restore, one GPR row per message, addressed by warp_id and row_idx so RCU writes it without state. The PC groups return to FET on ccv_pca_fet_mig.

pca → rcu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `row_idx` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | `CCV_L_W_PRED_STATE` | 1024 ⛔ | CCV_L_W_PRED_STATE (preliminary, churn **HIGH**) |
| **total** | | **2057** | ⛔ 1024 preliminary |

### `ccv_fet_pca_mig`

A demoted warp's PC groups, out to the parked array. FET owns the PC and its update logic, so the group PCs migrate from FET directly -- not through RCU, which would cross two blocks and hold state it has no other reason to touch. RAU sequences this and the RCU->PCA transfer and waits for both before reallocating the slot.

fet → pca · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| **total** | | **261** | ⛔ 256 preliminary |

### `ccv_pca_fet_mig`

A restored warp's PC groups, back to FET, which resumes fetch from them.

pca → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| **total** | | **261** | ⛔ 256 preliminary |

### `ccv_rau_fet_mig`

The migration command to FET, the same command ccv_rau_rcu_mig gives RCU: which warp, which direction, which parked bank. On demotion FET sends the warp's PC groups on ccv_fet_pca_mig. RAU sequences both halves of a migration, so both halves need the command.

rau → fet · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `bank_select` | `CCV_L_W_PCA_BANK` | 3 ⛔ | CCV_L_W_PCA_BANK (preliminary, churn med) |
| **total** | | **9** | ⛔ 3 preliminary |

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
