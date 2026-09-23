<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->

# Payload specification — all 40 channels

Every channel's payload, field by field. **15 of 40 channels**
have every field sized and generate a packed struct today; the
remaining 25 have at least one field with no decided width.

Two things this document is careful about:

- A width that is **decided** shows where it came from, so a
  reader can tell an ISA constant from an architectural choice
  from a provisional placeholder. Anything marked ⚠️ resolves
  through `ccv_prov_pkg` and is **not** a decision.
- A width that is **not decided** is left open with the specific
  question attached. No placeholder is supplied, because a
  placeholder reaches a generated typedef and gets believed,
  whereas an open field blocks loudly.

Channel shape is uniform and is not repeated per channel: four
signals — `_valid` and `_payload` from the producer, `_credit`
and `_stall` from the consumer — with valid one cycle ahead of
the payload. See `docs/interface-checker-convention.md`.

## Summary

| | Channels | Fields |
|---|---|---|
| Sized, every width decided | 5 | 14 |
| Sized, but some width provisional | 10 | 27 |
| Has an open field | 25 | 103 |
| **Total** | **40** | **144** |

Distinct field names with no decided width: **28**.

**"Sized" is not "decided."** 10 of the 15 channels that
generate a struct today do so through at least one provisional
width, so their layout will move when that parameter is settled.
Only **5 of 40** channels are decided end to end. The provisional
parameters those depend on:

- `CCV_P_LINE_BYTES` = 128 — Cache line size — **4 channels**
- `CCV_P_W_ROB_TAG` = 7 — Tier-1 id plus ROB depth — **3 channels**
- `CCV_P_W_CTA_SLOT` = 3 — Follows CCV_P_MAX_CTA — **2 channels**
- `CCV_P_W_PA` = 48 — Physical address width at the coherent boundary — **1 channel**
- `CCV_P_W_PHYS_REG` = 8 — Follows CCV_P_PHYS_REGS — **1 channel**

---

## What is needed, by owner

Grouped by who has to answer. A field appearing on several
channels is listed once; those are the ones where two sessions
deciding independently produce two incompatible encodings.

### cru, rau

**`demotion_threshold`** — 1 channel: `ccv_cru_rau_cfg`

Tier-1 demotion threshold, a CSR-programmed policy value. Width is a policy range decision, not an architectural one: state the units (cycles? retired instructions? MLC misses?) and the range worth expressing.

**`progress_threshold`** — 1 channel: `ccv_cru_rau_cfg`

Companion to demotion_threshold and the same decision: units and range. Both are tuning knobs, so they may reasonably be the widest thing a CSR write can carry rather than a tight fit.

### dcu, miu

**`data`** — 1 channel: `ccv_dcu_miu_rsp`

Read-return data on ccv_dcu_miu_rsp. Named `data` while the SPM path names the same concept `read_data` / `write_data` -- worth unifying. Width is the DCU beat, which needs stating: full line, or CCV_W_DATA, or a narrower beat with multiple transfers.

### dec

**`class`** — 1 channel: `ccv_dec_ooe_uop`

How many uop classes, and is class a strict partition of opcode space (so class is derivable from opcode and is carried only to save decode) or an orthogonal attribute? The answer sets whether this field is load-bearing or an optimisation.

### dec, ooe, rcu

**`opcode`** — 3 channels: `ccv_dec_ooe_uop`, `ccv_ooe_rcu_issue`, `ccv_rcu_lane_ops`

Same question, one level down: dec->ooe carries a decoded uop opcode, ooe->rcu carries what the scheduler issues, and rcu->lane carries what a lane actually executes. Is this one encoding narrowing along the pipe, or re-encoded at each hop? If it narrows, the width is set once by the widest (dec->ooe); if it re-encodes, three numbers. Note dec->ooe already carries a separate `class` field, so the split between class and opcode needs stating either way.

### exb

**`tilelink_tlc`** — 1 channel: `ccv_exb_ext`

> ⚑ Not a field width so much as an external protocol binding.

The only external-facing channel. This is a whole TileLink TL-C bundle, not a scalar: decide the TileLink parameters (beat width, source/sink id widths, address width) and whether this channel carries the flattened bundle or is decomposed into the five TL channels. Until then it cannot be given a single width.

### fet, miu, mlc, rau

**`asid`** — 3 channels: `ccv_fet_miu_itlb_req`, `ccv_fet_mlc_ifill`, `ccv_rau_fet_launch`

> ⚑ Only open field here that is clearly ONE encoding across its channels.

Address-space id width, i.e. how many address spaces are concurrently resident before an ASID rollover / TLB flush is required. Appears on both translation channels and on the launch channel, so it is the same field in all three; one number.

### memory hierarchy (miu, spm, dcu, mlc, exb)

**`op`** — 5 channels: `ccv_dcu_mlc_req`, `ccv_miu_dcu_req`, `ccv_miu_spm_req`, `ccv_mlc_exb_req`, `ccv_ooe_miu_memop`

> ⚑ Widest blast radius of any open field, and the one most likely to be wrong if each session decides alone.

Is this ONE encoding or three? It appears on five channels at three different levels: ccv_ooe_miu_memop (architectural memory op), ccv_miu_spm_req (scratchpad bank access), and ccv_miu_dcu_req / ccv_dcu_mlc_req / ccv_mlc_exb_req (cache-line request, where it must also carry coherence intent). A scratchpad bank has no notion of ownership and a cache line has no notion of a lane-strided access, so one shared encoding across all five looks unlikely. Decide whether to keep one field name with three widths or rename them apart; then give the operation list at each level.

### miu, dcu, mlc, exb

**`size`** — 2 channels: `ccv_miu_dcu_req`, `ccv_mlc_exb_req`

Access size at the cache level, on ccv_miu_dcu_req and ccv_mlc_exb_req. Distinct from the decided CCV_W_CHWIDTH (element width code, 2 bits) which lives at the architectural level. Give the legal transfer sizes -- if they are powers of two up to a line, this is a small code rather than a byte count.

### miu, fet

**`itlb_refill`** — 1 channel: `ccv_miu_fet_itlb`

The only field on ccv_miu_fet_itlb, so it is the whole payload: a translation result. Needs the iTLB entry format -- PPN (CCV_P_W_PA minus page offset) plus permissions plus whatever the refill FSM requires.

### miu, ooe

**`status`** — 1 channel: `ccv_miu_ooe_cmpl`

Completion status on ccv_miu_ooe_cmpl. The channel already carries a separate `cause` field (CCV_W_FAULT_CAUSE) and `mlc_miss`, so state what status adds beyond ok/fault -- if it is only ok/fault it is 1 bit and cause carries the rest.

### miu, spm

**`byte_mask`** — 1 channel: `ccv_miu_spm_req`

Write byte-enables on ccv_miu_spm_req. Almost certainly write_data/8, but write_data's own width is set by the SPM word size (CCV_W_SPM_WORD = 10 addresses 32-bit words), so confirm the beat width rather than assuming.

### mlc, exb

**`ownership_class`** — 1 channel: `ccv_mlc_exb_req`

Coherence ownership class on ccv_mlc_exb_req. Enumerate the states requested at this boundary (the MESI/MOESI subset actually used); the width falls out. Related to `op` on the same channel, so decide the two together -- ownership intent may belong inside op.

### ooe, cru

**`cta_id`** — 1 channel: `ccv_ooe_cru_fault`

CTA identifier on the fault channel. Distinct from the decided CCV_P_W_CTA_SLOT (3 bits, a hardware slot index): this looks like the software-visible CTA id from the launch grid, which is much wider. Confirm which is meant -- if it is the slot, reuse CCV_P_W_CTA_SLOT and rename the field.

### ooe, miu

**`ordering`** — 1 channel: `ccv_ooe_miu_memop`

Memory ordering / fence semantics carried per op. Enumerate the orderings the ISA exposes (relaxed, acquire, release, acq_rel, seq_cst?) and whether scope (CTA / core / system) is encoded in the same field or separately.

**`space`** — 1 channel: `ccv_ooe_miu_memop`

Memory space selector (global / shared / scratchpad / const / local?). Enumerate the spaces; the width is ceil(log2(count)) unless a one-hot is wanted for decode speed.

### ooe, rau

**`retired_since_restore`** — 1 channel: `ccv_ooe_rau_status`

Retire count since context restore, feeding the progress/demotion policy. Width is a saturation choice: pick the count at which the policy stops caring and saturate there, rather than sizing for a true maximum.

### rau, fet

**`code_bounds`** — 1 channel: `ccv_rau_fet_launch`

Code region bounds on launch. Two questions: is this a base+limit pair or a base+size, and is it at page granularity (narrowing it considerably) or byte granularity at CCV_W_VA?

### rau, miu

**`launch_block_addr`** — 1 channel: `ccv_rau_miu_cta`

Address of the CTA launch block in memory. Presumably CCV_W_VA or CCV_P_W_PA -- state which side of translation this is on, since the channel goes to the MIU.

### rau, ooe

**`prf_base`** — 1 channel: `ccv_rau_ooe_alloc`

Physical register file base for a warp's allocated window. Follows CCV_P_PHYS_REGS (CCV_P_W_PHYS_REG = 8 provisional), but confirm whether allocation is at register granularity or in fixed-size chunks -- chunked allocation narrows both this and prf_size.

**`prf_size`** — 1 channel: `ccv_rau_ooe_alloc`

Size of that window. Same granularity question as prf_base; the two are one decision.

### rau, rcu

**`bank_select`** — 1 channel: `ccv_rau_rcu_mig`

Which register bank a migration targets on ccv_rau_rcu_mig. Needs the banking factor of the PRF, which has not been stated anywhere yet.

### rcu, lane

**`operand`** — 1 channel: `ccv_rcu_lane_ops`

One operand's worth of data on ccv_rcu_lane_ops -- but the channel is per-lane at rate 4, so state whether this is one lane's element (CCV_W_LANE_DATA), a full row (CCV_W_DATA), or a bundle of N source operands. The rate and the width together set the wire cost of the whole execute path, so this one is worth getting right before floorplan.

**`sub_width`** — 1 channel: `ccv_rcu_lane_ops`

How a lane subdivides its 32-bit datapath for packed SIMD. If the legal set is exactly CCV_W_CHWIDTH's (32/16/8/4) then this is that code and should say so rather than being a second field; if lanes support something chwidth cannot express, state what.

### rcu, miu

**`index_per_lane`** — 1 channel: `ccv_rcu_miu_addr`

Per-lane index for a gather/scatter on ccv_rcu_miu_addr. Two numbers needed: the index width per lane, and whether all 32 lanes ship per beat or a subset. At 32 lanes x a 32-bit index this is a 1024-bit field, so if that is not intended the channel needs a narrower index or more beats.

### rcu, pca

**`pcs`** — 2 channels: `ccv_pca_rcu_mig`, `ccv_rcu_pca_mig`

PLURAL, and that is the question: how many PCs travel in one migration? SMT-4 tier-1 suggests four, but the channel moves a whole parked context, so it may be one PC per warp in the migrating group, or one per divergence-stack entry. State what the set is over, then the count follows CCV_W_VA times that.

**`pred_state`** — 2 channels: `ccv_pca_rcu_mig`, `ccv_rcu_pca_mig`

Predicate/divergence state for a migrating context. Needs the divergence representation first: a reconvergence stack of N entries (depth x (mask + PC)) or a flat per-lane mask set. This is the field most likely to be underestimated, because it is where the divergence model is actually stored.

### spm, miu

**`conflict_serialization`** — 1 channel: `ccv_spm_miu_rsp`

Reported bank-conflict serialisation on ccv_spm_miu_rsp. Is this a count of extra cycles taken (width = log2 of worst-case serialisation, bounded by 32 banks) or a per-lane conflict bitmap? A count is cheap and enough for the timing model; a bitmap is what a debug trace would want.

---

## Channels with every field sized

These generate a packed struct into both languages today.

### `ccv_fet_dec_instr`

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

lane → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `result` | `CCV_W_LANE_DATA` | 32 | CCV_W_LANE_DATA (isa) |
| `lane_fault` | `1` | 1 | literal |
| **total** | | **33** | |

### `ccv_rcu_ooe_done`

rcu → ooe · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `exec_fault` | `1` | 1 | literal |
| `fault_lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| **total** | | **40** | ⚠️ 7 of these bits are provisional |

### `ccv_miu_rcu_data`

miu → rcu · rate 4 · execution

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `load_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| **total** | | **1039** | ⚠️ 15 of these bits are provisional |

### `ccv_ooe_miu_retire`

ooe → miu · rate 4 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `commit_or_discard` | `1` | 1 | literal |
| **total** | | **8** | ⚠️ 7 of these bits are provisional |

### `ccv_mlc_dcu_rsp`

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1026** | ⚠️ 1024 of these bits are provisional |

### `ccv_mlc_dcu_probe`

mlc → dcu · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `invalidate_or_downgrade` | `1` | 1 | literal |
| **total** | | **49** | ⚠️ 48 of these bits are provisional |

### `ccv_dcu_mlc_probe_ack`

dcu → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `ack` | `1` | 1 | literal |
| `dirty_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1025** | ⚠️ 1024 of these bits are provisional |

### `ccv_mlc_fet_ifill_rsp`

mlc → fet · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| **total** | | **1024** | ⚠️ 1024 of these bits are provisional |

### `ccv_exb_mlc_rsp`

exb → mlc · rate 1 · memory

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `line_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |
| `ownership_grant` | `1` | 1 | literal |
| `inbound_probe` | `1` | 1 | literal |
| `miss` | `1` | 1 | literal |
| **total** | | **1027** | ⚠️ 1024 of these bits are provisional |

### `ccv_rau_ooe_demote`

rau → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `squash_to_retirement` | `1` | 1 | literal |
| **total** | | **6** | |

### `ccv_ooe_rau_drained`

ooe → rau · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `resume_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `arch_state_ready` | `1` | 1 | literal |
| **total** | | **70** | |

### `ccv_ooe_syu_bar`

ooe → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| `arrive_or_wait` | `1` | 1 | literal |
| **total** | | **13** | ⚠️ 3 of these bits are provisional |

### `ccv_syu_ooe_rel`

syu → ooe · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_mask_released` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `barrier_id` | `CCV_W_BAR_ID` | 4 | CCV_W_BAR_ID (arch) |
| **total** | | **9** | |

### `ccv_rau_syu_alloc`

rau → syu · rate 1 · control

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `barrier_entries` | `CCV_W_BAR_ENTRY` | 6 | CCV_W_BAR_ENTRY (arch) |
| `allocate_or_free` | `1` | 1 | literal |
| **total** | | **10** | ⚠️ 3 of these bits are provisional |

## Channels with at least one open field

These generate topology only — no packed struct — until every
field is sized.

### `ccv_dec_ooe_uop`

dec → ooe · rate 6 · instruction · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `class` | — | — | **OPEN — see below** |
| `opcode` | — | — | **OPEN — see below** |
| `src_arch` | `2*CCV_W_ARCH_REG` | 8 | CCV_W_ARCH_REG (isa) |
| `dst_arch` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `pred_reg` | `CCV_W_ARCH_REG` | 4 | CCV_W_ARCH_REG (isa) |
| `imm` | `CCV_P_W_IMM` | 32 ⚠️ | CCV_P_W_IMM (provisional) |
| `decode_fault` | `1` | 1 | literal |

Open: `class`, `opcode`

### `ccv_ooe_rcu_issue`

ooe → rcu · rate 4 · execution · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `phys_src` | `2*CCV_P_W_PHYS_REG` | 16 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_dst` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `phys_pred` | `CCV_P_W_PHYS_REG` | 8 ⚠️ | CCV_P_W_PHYS_REG (provisional) |
| `opcode` | — | — | **OPEN — see below** |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `dispatch_fault` | `1` | 1 | literal |

Open: `opcode`

### `ccv_rcu_lane_ops`

rcu → lane · rate 4 · execution · **3 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `opcode` | — | — | **OPEN — see below** |
| `sub_width` | — | — | **OPEN — see below** |
| `operand` | — | — | **OPEN — see below** |
| `pred_bit` | `1` | 1 | literal |
| `section_en` | `4` | 4 | literal |

Open: `opcode`, `sub_width`, `operand`

### `ccv_rcu_miu_addr`

rcu → miu · rate 4 · execution · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `base` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `index_per_lane` | — | — | **OPEN — see below** |
| `store_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |

Open: `index_per_lane`

### `ccv_ooe_miu_memop`

ooe → miu · rate 4 · memory · **3 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `op` | — | — | **OPEN — see below** |
| `chwidth` | `CCV_W_CHWIDTH` | 2 | CCV_W_CHWIDTH (isa) |
| `space` | — | — | **OPEN — see below** |
| `ordering` | — | — | **OPEN — see below** |

Open: `op`, `space`, `ordering`

### `ccv_miu_ooe_cmpl`

miu → ooe · rate 4 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `rob_tag` | `CCV_P_W_ROB_TAG` | 7 ⚠️ | CCV_P_W_ROB_TAG (provisional) |
| `status` | — | — | **OPEN — see below** |
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `address` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `mlc_miss` | `1` | 1 | literal |

Open: `status`

### `ccv_miu_spm_req`

miu → spm · rate 4 · memory · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `bank_addr` | `CCV_W_SPM_BANK` | 5 | CCV_W_SPM_BANK (arch) |
| `write_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `byte_mask` | — | — | **OPEN — see below** |
| `op` | — | — | **OPEN — see below** |

Open: `byte_mask`, `op`

### `ccv_spm_miu_rsp`

spm → miu · rate 4 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `read_data` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `conflict_serialization` | — | — | **OPEN — see below** |

Open: `conflict_serialization`

### `ccv_miu_dcu_req`

miu → dcu · rate 4 · memory · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | — | — | **OPEN — see below** |
| `op` | — | — | **OPEN — see below** |
| `exclusive_req` | `1` | 1 | literal |

Open: `size`, `op`

### `ccv_dcu_miu_rsp`

dcu → miu · rate 4 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `data` | — | — | **OPEN — see below** |
| `hit` | `1` | 1 | literal |
| `ownership_granted` | `1` | 1 | literal |

Open: `data`

### `ccv_dcu_mlc_req`

dcu → mlc · rate 1 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `op` | — | — | **OPEN — see below** |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |

Open: `op`

### `ccv_fet_mlc_ifill`

fet → mlc · rate 1 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `asid` | — | — | **OPEN — see below** |

Open: `asid`

### `ccv_miu_fet_itlb`

miu → fet · rate 1 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `itlb_refill` | — | — | **OPEN — see below** |

Open: `itlb_refill`

### `ccv_fet_miu_itlb_req`

fet → miu · rate 1 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `virtual_page` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `asid` | — | — | **OPEN — see below** |

Open: `asid`

### `ccv_mlc_exb_req`

mlc → exb · rate 1 · memory · **3 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `phys_addr` | `CCV_P_W_PA` | 48 ⚠️ | CCV_P_W_PA (provisional) |
| `size` | — | — | **OPEN — see below** |
| `op` | — | — | **OPEN — see below** |
| `ownership_class` | — | — | **OPEN — see below** |
| `core_id` | `CCV_W_CORE_ID` | 2 | CCV_W_CORE_ID (arch) |
| `writeback_data` | `8*CCV_P_LINE_BYTES` | 1024 ⚠️ | CCV_P_LINE_BYTES (provisional) |

Open: `size`, `op`, `ownership_class`

### `ccv_exb_ext`

exb → EXTERNAL · rate 1 · memory · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `tilelink_tlc` | — | — | **OPEN — see below** |

Open: `tilelink_tlc`

### `ccv_rau_fet_launch`

rau → fet · rate 1 · control · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `start_pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `code_bounds` | — | — | **OPEN — see below** |
| `asid` | — | — | **OPEN — see below** |
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |

Open: `code_bounds`, `asid`

### `ccv_rau_ooe_alloc`

rau → ooe · rate 1 · control · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `prf_base` | — | — | **OPEN — see below** |
| `prf_size` | — | — | **OPEN — see below** |
| `activate_or_free` | `1` | 1 | literal |

Open: `prf_base`, `prf_size`

### `ccv_ooe_rau_status`

ooe → rau · rate 1 · control · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `stalled` | `1` | 1 | literal |
| `mlc_miss_seen` | `1` | 1 | literal |
| `retired_since_restore` | — | — | **OPEN — see below** |

Open: `retired_since_restore`

### `ccv_rau_rcu_mig`

rau → rcu · rate 1 · control · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |
| `direction` | `1` | 1 | literal |
| `bank_select` | — | — | **OPEN — see below** |

Open: `bank_select`

### `ccv_rcu_pca_mig`

rcu → pca · rate 1024 · control · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | — | — | **OPEN — see below** |
| `pcs` | — | — | **OPEN — see below** |

Open: `pred_state`, `pcs`

### `ccv_pca_rcu_mig`

pca → rcu · rate 1024 · control · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `gpr_row` | `CCV_W_DATA` | 1024 | CCV_W_DATA (isa) |
| `pred_state` | — | — | **OPEN — see below** |
| `pcs` | — | — | **OPEN — see below** |

Open: `pred_state`, `pcs`

### `ccv_rau_miu_cta`

rau → miu · rate 1 · control · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cta_slot` | `CCV_P_W_CTA_SLOT` | 3 ⚠️ | CCV_P_W_CTA_SLOT (provisional) |
| `spm_base` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `spm_limit` | `CCV_W_SPM_ADDR` | 17 | CCV_W_SPM_ADDR (arch) |
| `launch_block_addr` | — | — | **OPEN — see below** |

Open: `launch_block_addr`

### `ccv_ooe_cru_fault`

ooe → cru · rate 1 · control · **1 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `cause` | `CCV_W_FAULT_CAUSE` | 4 | CCV_W_FAULT_CAUSE (arch) |
| `pc` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `lane_mask` | `CCV_W_LANE_MASK` | 32 | CCV_W_LANE_MASK (isa) |
| `address` | `CCV_W_VA` | 64 | CCV_W_VA (arch) |
| `cta_id` | — | — | **OPEN — see below** |
| `warp_id` | `CCV_W_WARP_ID` | 5 | CCV_W_WARP_ID (arch) |

Open: `cta_id`

### `ccv_cru_rau_cfg`

cru → rau · rate 1 · control · **2 open**

| Field | Width expression | Bits | Source |
|---|---|---|---|
| `demotion_threshold` | — | — | **OPEN — see below** |
| `progress_threshold` | — | — | **OPEN — see below** |
| `launch_enable` | `1` | 1 | literal |

Open: `demotion_threshold`, `progress_threshold`
