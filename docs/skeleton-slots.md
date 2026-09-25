<!-- GENERATED FILE -- DO NOT EDIT. Produced by tools/gen-skel.py;
     tools/verify.sh fails if it is stale. -->

# Skeleton slot derivation

Every credited slot the skeleton builds, derived from
`schema/interfaces.json` and `params/blocks.json`: a channel type has
`rate` slots per instance, and one instance per instance of a
multi-instance endpoint (LANE has 32).

## The count

| Channel types | Rate | Instances each | Slots |
|---|---|---|---|
| 26 | 1 | 1 | 26 |
| 11 | 4 | 1 | 44 |
| 2 | 4 | 32 | 256 |
| 1 | 6 | 1 | 6 |
| 1 | 8 | 1 | 8 |
| **41** | | | **340** |

41 channel types; **103 channel instances** (39 types at one instance, plus 2 at 32 each); **340 slots**, one `ccv_credit_checker` each.

The terms that matter most are the ones multiplied by 32: a rate wrong by one on either lane channel moves the total by 32 and every run stays clean.

## Every channel, with its slot attributes

Slot attributes apply to rate > 1 only; lockstep to channels replicated across a multi-instance endpoint. *Italic* is the permissive default; **bold** is decided, with the reason.

| # | Channel | Rate × inst | Slots | Acceptance | Binding | Ordering key | Lockstep | Id classes |
|---|---|---|---|---|---|---|---|---|
| 0 | `ccv_fet_dec_instr` | 8 × 1 | 8 | *partial* | **bound, groups of 2** — four warp streams of two: tier-1 stream = slot / 2 | **slot_group** — each stream's two slots are strictly program-ordered | — | instr |
| 1 | `ccv_dec_ooe_uop` | 6 × 1 | 6 | *partial* | *free* | **warp_id** — six uops from up to four warps have no total order; order is per warp | — | instr |
| 2 | `ccv_ooe_rcu_issue` | 4 × 1 | 4 | *partial* | **free** — the four issue slots are a free pool | *none* | — | instr |
| 3 | `ccv_rcu_lane_ops` | 4 × 32 | 128 | *partial* | **bound, groups of 1** — lane N's four operands slots correspond one-to-one with the four issue slots; free would let lane 3 take instruction A in slot 0 while lane 7 takes it in slot 2 | *none* | **true** — the 32 lanes are one SIMD datapath: they advance together, with no per-lane flow control | instr |
| 4 | `ccv_lane_rcu_res` | 4 × 32 | 128 | *partial* | **bound, groups of 1** — lane N's four results slots correspond one-to-one with the four issue slots; free would let lane 3 take instruction A in slot 0 while lane 7 takes it in slot 2 | *none* | **true** — the 32 lanes are one SIMD datapath: they advance together, with no per-lane flow control | instr |
| 5 | `ccv_rcu_ooe_done` | 4 × 1 | 4 | *partial* | *free* | *none* | — | instr |
| 6 | `ccv_rcu_miu_addr` | 4 × 1 | 4 | *partial* | *free* | *none* | — | instr |
| 7 | `ccv_miu_rcu_data` | 4 × 1 | 4 | *partial* | *free* | *none* | — | instr |
| 8 | `ccv_ooe_miu_memop` | 4 × 1 | 4 | *partial* | *free* | *none* | — | instr |
| 9 | `ccv_miu_ooe_cmpl` | 4 × 1 | 4 | *partial* | *free* | **none** — genuinely out of order across four pipes | — | instr |
| 10 | `ccv_ooe_miu_retire` | 4 × 1 | 4 | *partial* | *free* | *none* | — | instr |
| 11 | `ccv_miu_spm_req` | 4 × 1 | 4 | *partial* | *free* | *none* | — | txn |
| 12 | `ccv_spm_miu_rsp` | 4 × 1 | 4 | *partial* | *free* | *none* | — | txn |
| 13 | `ccv_miu_dcu_req` | 4 × 1 | 4 | *partial* | *free* | *none* | — | txn |
| 14 | `ccv_dcu_miu_rsp` | 4 × 1 | 4 | *partial* | *free* | *none* | — | txn |
| 15 | `ccv_dcu_mlc_req` | 1 × 1 | 1 | — | — | — | — | txn |
| 16 | `ccv_mlc_dcu_rsp` | 1 × 1 | 1 | — | — | — | — | txn |
| 17 | `ccv_mlc_dcu_probe` | 1 × 1 | 1 | — | — | — | — | none |
| 18 | `ccv_dcu_mlc_probe_ack` | 1 × 1 | 1 | — | — | — | — | none |
| 19 | `ccv_fet_mlc_ifill` | 1 × 1 | 1 | — | — | — | — | txn |
| 20 | `ccv_mlc_fet_ifill_rsp` | 1 × 1 | 1 | — | — | — | — | txn |
| 21 | `ccv_miu_fet_itlb` | 1 × 1 | 1 | — | — | — | — | txn |
| 22 | `ccv_fet_miu_itlb_req` | 1 × 1 | 1 | — | — | — | — | txn |
| 23 | `ccv_mlc_exb_req` | 1 × 1 | 1 | — | — | — | — | txn |
| 24 | `ccv_exb_mlc_rsp` | 1 × 1 | 1 | — | — | — | — | txn, none |
| 25 | `ccv_exb_ext_out` | 1 × 1 | 1 | — | — | — | — | txn |
| 26 | `ccv_rau_fet_launch` | 1 × 1 | 1 | — | — | — | — | none |
| 27 | `ccv_rau_ooe_alloc` | 1 × 1 | 1 | — | — | — | — | none |
| 28 | `ccv_ooe_rau_status` | 1 × 1 | 1 | — | — | — | — | none |
| 29 | `ccv_rau_ooe_demote` | 1 × 1 | 1 | — | — | — | — | none |
| 30 | `ccv_ooe_rau_drained` | 1 × 1 | 1 | — | — | — | — | none |
| 31 | `ccv_rau_rcu_mig` | 1 × 1 | 1 | — | — | — | — | none |
| 32 | `ccv_rcu_pca_mig` | 1 × 1 | 1 | — | — | — | — | none |
| 33 | `ccv_pca_rcu_mig` | 1 × 1 | 1 | — | — | — | — | none |
| 34 | `ccv_rau_miu_cta` | 1 × 1 | 1 | — | — | — | — | none |
| 35 | `ccv_ooe_syu_bar` | 1 × 1 | 1 | — | — | — | — | instr |
| 36 | `ccv_syu_ooe_rel` | 1 × 1 | 1 | — | — | — | — | none |
| 37 | `ccv_rau_syu_alloc` | 1 × 1 | 1 | — | — | — | — | none |
| 38 | `ccv_ooe_cru_fault` | 1 × 1 | 1 | — | — | — | — | instr |
| 39 | `ccv_cru_rau_cfg` | 1 × 1 | 1 | — | — | — | — | none |
| 40 | `ccv_ext_exb_in` | 1 × 1 | 1 | — | — | — | — | txn, none |
