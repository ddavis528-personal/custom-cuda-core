<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->

# Payload specification — all 40 channels

Every payload field has a width, so **every one of the 40
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
| All decided | 10 | 28 |
| ⚠️ Some provisional | 14 | 46 |
| ⛔ Some preliminary | 16 | 70 |
| **Total** | **40** | **144** |

## What still has to be decided

Grouped by who decides. Highest churn first within each group,
because those are the ones where a skeleton that reads the field
— rather than merely carrying it — will need rework.

### DEC block session -- is class derivable from opcode?

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_CLASS` | 3 | low | Eight uop classes: integer, float, SFU and convert, memory, control, collective, predicate, spare. DEC decides whether class is derivable from opcode at all. |

### EXB session -- flattened bundle or five channels

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_TILELINK_TLC` | 1760 | **HIGH** | Five TL channels with a 512-bit beat, 48-bit address, 6-bit source and 4-bit sink. Not really a width: EXB decides whether the channel carries a flattened bundle or decomposes into five. |

### ISA opcode census, then DEC/OOE/RCU agree the hops

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_OPCODE` | 9 | **HIGH** | One encoding across all three hops until proven otherwise. Narrowing at RCU->LANE is likely, but the ISA opcode census sets it. Anything decoding this field will be rewritten. |

### MIU block session

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_MEM_OP` | 4 | med | Architectural memory operation: load, store, atomic family, prefetch, fence. |

### MLC/EXB session, alongside CCV_L_W_COH_OP

| Parameter | Value | Churn | Basis |
|---|---|---|---|
| `CCV_L_W_OWNERSHIP` | 3 | med | TL-C permission levels plus an explicit dirty bit, kept wider than TL-C needs so a CHI bridge maps without a second translation. |

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

### rcu miu width

*partitioning question that a width exposed — partitioning / floorplan*

ccv_rcu_miu_addr carries index_per_lane (1024) beside store_data (1024) at rate 4 -- roughly 8,400 wires from RCU into MIU, almost certainly the widest interface in the design. It argues for co-locating the AGUs with RCU, or moving address generation into the register read stage.

**Blocks:** Nothing today -- the skeleton does not care how wide a bus is. Settle before floorplan rather than after, since the answer may move a block boundary and block boundaries are swap boundaries.

### src arch vs operand

*ISA question, not an RTL one — ISA / compiler track*

ccv_dec_ooe_uop carries TWO source registers (src_arch = 2*CCV_W_ARCH_REG) while ccv_rcu_lane_ops carries THREE operands (CCV_L_OPERANDS_PER_LANE = 3). Either the third operand is the destination read back for accumulate -- in which case rename must treat dst_arch as a source -- or the ISA has true three-source operations and src_arch is one field short. dp4 and dp8 make the second likely.

**Blocks:** Rename cannot be coded until this settles. The skeleton can be wired either way, because both sides already have a width; what it changes is which field rename READS, so a skeleton written against the wrong answer needs rework at 4a rather than now.

---

## Every channel

## All widths decided

### `ccv_fet_dec_instr`

Fetched, length-decoded, aligned instruction words, two per warp across all four tier-1 warps. Fetch faults ride here rather than a separate path.

fet → dec · rate 8 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `instr` | `CCV_W_INSTR` | 48 | CCV_W_INSTR (isa) |
| `length` | `CCV_W_ILEN` | 2 | CCV_W_ILEN (isa) |
| `fetch_fault` | `1` | 1 | literal |
| **total** | | **120** | |

### `ccv_lane_rcu_res`

One lane's result and its fault bit.

lane → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `result` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `lane_fault` | `1` | 1 | literal |
| **total** | | **33** | |

### `ccv_spm_miu_rsp`

Scratchpad read data plus how many extra cycles conflicts cost, which the timing model needs.

spm → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `conflict_serialization` | `CCV_W_CONFLICT_SER` | 6 | CCV_W_CONFLICT_SER (arch) |
| **total** | | **1030** | |

### `ccv_dcu_miu_rsp`

Cache read data, hit indication and whether ownership was granted.

dcu → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `hit` | `1` | 1 | literal |
| `ownership_granted` | `1` | 1 | literal |
| **total** | | **1026** | |

### `ccv_fet_miu_itlb_req`

Fetch asking the walker for a translation on an ITLB miss.

fet → miu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `virtual_page` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| **total** | | **72** | |

### `ccv_ooe_rau_status`

Per-warp stall and progress reporting, feeding demotion policy.

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `stalled` | `1` | 1 | literal |
| `mlc_miss_seen` | `1` | 1 | literal |
| `retired_since_restore` | `CCV_W_RETIRED_CNT` | 8 | CCV_W_RETIRED_CNT (arch) |
| **total** | | **15** | |

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

### `ccv_syu_ooe_rel`

The set of warps a barrier released.

syu → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_mask_released` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| **total** | | **36** | |

### `ccv_cru_rau_cfg`

Host-programmed policy: demotion threshold, progress threshold, launch enable.

cru → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `demotion_threshold` | `CCV_W_CSR` | 32 | CCV_W_CSR (arch) |
| `progress_threshold` | `CCV_W_CSR` | 32 | CCV_W_CSR (arch) |
| `launch_enable` | `1` | 1 | literal |
| **total** | | **65** | |

## ⚠️ Carries a provisional width

### `ccv_rcu_ooe_done`

Completion back to the ROB for arithmetic, with the faulting lane mask.

rcu → ooe · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `exec_fault` | `1` | 1 | literal |
| `fault_lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **40** | ⚠️ 7 provisional |

### `ccv_rcu_miu_addr`

Address operands and store data for memory operations. The widest interface in the design.

rcu → miu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `base` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `index_per_lane` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `store_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **2119** | ⚠️ 7 provisional |

### `ccv_miu_rcu_data`

Load return data written into the register file.

miu → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `load_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1039** | ⚠️ 15 provisional |

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

### `ccv_mlc_dcu_rsp`

Line fills and ownership grants back to L1.

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1026** | ⚠️ 1024 provisional |

### `ccv_mlc_dcu_probe`

Inbound invalidate or downgrade. Unsolicited, and a wake source, since a sleeping D-cache must still answer.

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `invalidate_or_downgrade` | `1` | 1 | literal |
| **total** | | **49** | ⚠️ 48 provisional |

### `ccv_dcu_mlc_probe_ack`

Probe response, carrying dirty data when the line was modified.

dcu → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `ack` | `1` | 1 | literal |
| `dirty_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1025** | ⚠️ 1024 provisional |

### `ccv_fet_mlc_ifill`

Instruction cache miss straight to MLC, bypassing the D-cache.

fet → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `asid` | `CCV_W_ASID` | 8 | CCV_W_ASID (arch) |
| **total** | | **56** | ⚠️ 48 provisional |

### `ccv_mlc_fet_ifill_rsp`

Instruction line fill.

mlc → fet · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1024** | ⚠️ 1024 provisional |

### `ccv_exb_mlc_rsp`

Protocol-neutral inbound: fills, grants and probes.

exb → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership_grant` | `1` | 1 | literal |
| `inbound_probe` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1027** | ⚠️ 1024 provisional |

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

Format-decoded operations with architectural register names, six per cycle into the queue ahead of rename.

dec → ooe · rate 6 · instruction

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `uop_class` | `CCV_L_W_CLASS` | 3 ⛔ | CCV_L_W_CLASS (preliminary, churn low) |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `src_arch` | `2*CCV_W_ARCH_REG` | 8 | CCV_W_ARCH_REG (isa) |
| `dst_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `pred_reg` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `decode_fault` | `1` | 1 | literal |
| **total** | | **130** | ⛔ 12 preliminary, ⚠️ 32 provisional |

### `ccv_ooe_rcu_issue`

What the scheduler selected: physical register names, opcode, element width. Four per cycle, the binding width of the machine.

ooe → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `phys_src` | `2*CCV_P_W_PHYS_REG` | 16 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_PRED` | 8 ⚠️ | CCV_P_W_PHYS_PRED (provisional) |
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `dispatch_fault` | `1` | 1 | literal |
| **total** | | **56** | ⛔ 9 preliminary, ⚠️ 39 provisional |

### `ccv_rcu_lane_ops`

Operands and control to one lane. Section enables gate the narrow sub-datapaths and the SFU.

rcu → lane · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `opcode` | `CCV_L_W_OPCODE` | 9 ⛔ | CCV_L_W_OPCODE (preliminary, churn **HIGH**) |
| `operand` | `CCV_L_OPERANDS_PER_LANE*CCV_W_LANE_DATA` | 96 ⛔ | CCV_L_OPERANDS_PER_LANE (preliminary, churn **HIGH**); CCV_W_LANE_DATA (isa) |
| `pred_bit` | `1` | 1 | literal |
| `section_en` | `4` | 4 | literal |
| **total** | | **110** | ⛔ 105 preliminary |

### `ccv_ooe_miu_memop`

The memory operation itself: space, ordering, element width, CTA slot for bounds checking.

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `mem_op` | `CCV_L_W_MEM_OP` | 4 ⛔ | CCV_L_W_MEM_OP (preliminary, churn med) |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `space` | `CCV_L_W_SPACE` | 3 ⛔ | CCV_L_W_SPACE (preliminary, churn low) |
| `ordering` | `CCV_L_W_ORDERING` | 4 ⛔ | CCV_L_W_ORDERING (preliminary, churn med) |
| **total** | | **28** | ⛔ 11 preliminary, ⚠️ 10 provisional |

### `ccv_miu_spm_req`

Scratchpad access with a per-bank address set. Bank conflicts resolve inside SPM.

miu → spm · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `bank_addr` | `CCV_SPM_BANKS*CCV_W_SPM_WORD` | 320 | CCV_SPM_BANKS (arch); CCV_W_SPM_WORD (arch) |
| `write_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `byte_mask` | `CCV_W_DATA/8` | 128 | CCV_W_DATA (isa) |
| `spm_op` | `CCV_L_W_SPM_OP` | 2 ⛔ | CCV_L_W_SPM_OP (preliminary, churn low) |
| **total** | | **1474** | ⛔ 2 preliminary |

### `ccv_miu_dcu_req`

Cache access, physically addressed, with the exclusive-ownership request for atomics.

miu → dcu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | `CCV_W_ACCESS_SIZE` | 3 | CCV_W_ACCESS_SIZE (arch) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `exclusive_req` | `1` | 1 | literal |
| **total** | | **56** | ⛔ 4 preliminary, ⚠️ 48 provisional |

### `ccv_dcu_mlc_req`

Fills and writebacks from L1 to the shared cache, tagged with core ID.

dcu → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1078** | ⛔ 4 preliminary, ⚠️ 1072 provisional |

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
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | `CCV_W_ACCESS_SIZE` | 3 | CCV_W_ACCESS_SIZE (arch) |
| `coh_op` | `CCV_L_W_COH_OP` | 4 ⛔ | CCV_L_W_COH_OP (preliminary, churn med) |
| `ownership_class` | `CCV_L_W_OWNERSHIP` | 3 ⛔ | CCV_L_W_OWNERSHIP (preliminary, churn med) |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1084** | ⛔ 7 preliminary, ⚠️ 1072 provisional |

### `ccv_exb_ext`

TileLink TL-C. The only channel outside our conventions.

exb → EXTERNAL · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `tilelink_tlc` | `CCV_L_W_TILELINK_TLC` | 1760 ⛔ | CCV_L_W_TILELINK_TLC (preliminary, churn **HIGH**) |
| **total** | | **1760** | ⛔ 1760 preliminary |

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

The warp's physical register window, activated or freed.

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `prf_base` | `CCV_L_W_PRF_BASE` | 8 ⛔ | CCV_L_W_PRF_BASE (preliminary, churn med) |
| `prf_size` | `CCV_L_W_PRF_SIZE` | 8 ⛔ | CCV_L_W_PRF_SIZE (preliminary, churn med) |
| `activate_or_free` | `1` | 1 | literal |
| **total** | | **22** | ⛔ 16 preliminary |

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

Architectural state out to the parked array on demotion.

rcu → pca · rate 1024 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | `CCV_L_W_PRED_STATE` | 1024 ⛔ | CCV_L_W_PRED_STATE (preliminary, churn **HIGH**) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| **total** | | **2304** | ⛔ 1280 preliminary |

### `ccv_pca_rcu_mig`

Architectural state back in on restore.

pca → rcu · rate 1024 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | `CCV_L_W_PRED_STATE` | 1024 ⛔ | CCV_L_W_PRED_STATE (preliminary, churn **HIGH**) |
| `pcs` | `CCV_L_PC_GROUPS*CCV_W_VA` | 256 ⛔ | CCV_L_PC_GROUPS (preliminary, churn **HIGH**); CCV_W_VA (arch) |
| **total** | | **2304** | ⛔ 1280 preliminary |

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
