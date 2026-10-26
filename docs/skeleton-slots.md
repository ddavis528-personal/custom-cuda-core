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
| 37 | 1 | 1 | 37 |
| 2 | 1 | 32 | 64 |
| 12 | 4 | 1 | 48 |
| 1 | 6 | 1 | 6 |
| 1 | 7 | 1 | 7 |
| 1 | 8 | 1 | 8 |
| 1 | 9 | 1 | 9 |
| **55** | | | **179** |

55 channel types; **117 channel instances** (53 types at one instance, plus 2 at 32 each); **179 slots**, one `ccv_common_chk_credit` each.

The terms that matter most are the ones multiplied by 32: a rate wrong by one on either lane channel moves the total by 32 and every run stays clean.

## Every channel, with its slot attributes

Slot attributes apply to rate > 1 only; lockstep to channels replicated across a multi-instance endpoint; fixed latency to any channel. *Italic* is the permissive default; **bold** is decided, with the reason.

| # | Channel | Rate × inst | Slots | Acceptance | Binding | Ordering key | Lockstep | Fixed latency | Id classes |
|---|---|---|---|---|---|---|---|---|---|
| 0 | `ccv_fet_dec_instr` | 8 × 1 | 8 | *partial* | **bound, groups of 2** — four warp streams of two: tier-1 stream = slot / 2 | **slot_group** — each stream's two slots are strictly program-ordered | — | *false* | instr |
| 1 | `ccv_ooe_fet_decq_credit` | 4 × 1 | 4 | *partial* | **bound, groups of 1** — slot k is tier-1 warp k's return, so every warp's credits return in the cycle they free, whatever the others do | **slot_group** — a warp's returns are one stream, in the order its slots left the queue | — | *false* | none |
| 2 | `ccv_dec_ooe_uop` | 6 × 1 | 6 | *partial* | *free* | **warp_id** — six uops from up to four warps have no total order; order is per warp | — | *false* | instr |
| 3 | `ccv_ooe_rcu_issue` | 9 × 1 | 9 | *partial* | **bound, groups of 1** — slot k is select resource k, CCV_ISSUE_RESOURCES in all: the lane sections S0-S3, the MIU pipes P0-P3, then the RCU unit R. An op sits in its lowest resource's slot and marks every other resource of its footprint continuation, so RCU sees which sections and pipes each cycle's ops hold; free slots would hide that | *none* | — | **true** — once RCU accepts an issue, the result lands exactly at its contracted latency; OOE schedules wakeup from that and has no grant or late signal to learn otherwise (A-47, Q-51) | instr |
| 4 | `ccv_rcu_lane_ops` | 1 × 32 | 32 | — | — | — | **true** — the 32 lanes are one SIMD datapath: they advance together, with no per-lane flow control | **true** — the lane pipeline is part of the contracted lane latency; a lane that stalled would slip every dependant OOE has already scheduled (A-47) | instr |
| 5 | `ccv_lane_rcu_res` | 1 × 32 | 32 | — | — | — | **true** — the 32 lanes are one SIMD datapath: they advance together, with no per-lane flow control | **true** — lane results land in the PRF at the contracted cycle; RCU never holds one (A-47) | instr |
| 6 | `ccv_rcu_ooe_done` | 7 × 1 | 7 | *partial* | *free* | *none* | — | **true** — completion at the contracted cycle is what OOE retires against; no late or cancel bit exists (A-47) | instr |
| 7 | `ccv_rcu_miu_addr` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | instr |
| 8 | `ccv_miu_rcu_data` | 4 × 1 | 4 | *partial* | *free* | *none* | — | **true** — L1-hit data must be in the PRF at the contracted cycle, since dependants woken at hit latency read it (A-47) | instr |
| 9 | `ccv_ooe_miu_memop` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | instr, none |
| 10 | `ccv_miu_ooe_cmpl` | 4 × 1 | 4 | *partial* | *free* | **none** — genuinely out of order across four pipes | — | **true** — an L1 hit completes at exactly the contracted cycle and no completion then is the miss indication (A-46), which only means something if OOE never delays taking a completion (A-47) | instr |
| 11 | `ccv_ooe_miu_retire` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | instr |
| 12 | `ccv_ooe_fet_redirect` | 1 × 1 | 1 | — | — | — | — | **true** — A-58: latency-matched with ccv_ooe_fet_ckpt_free; if FET could stall a redirect, a free sent after it could be applied before it and release a checkpoint the redirect is restoring. | instr |
| 13 | `ccv_ooe_fet_ckpt_free` | 1 × 1 | 1 | — | — | — | — | **true** — A-56: one bitmap frees any number of checkpoints, so FET can always take it the cycle it lands; a stalled free would hold a checkpoint FET could reuse. | none |
| 14 | `ccv_miu_spm_req` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | txn |
| 15 | `ccv_spm_miu_rsp` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | txn |
| 16 | `ccv_miu_dcu_req` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | txn |
| 17 | `ccv_dcu_miu_rsp` | 4 × 1 | 4 | *partial* | *free* | *none* | — | *false* | txn |
| 18 | `ccv_dcu_mlc_req` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 19 | `ccv_mlc_dcu_rsp` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 20 | `ccv_mlc_dcu_probe` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 21 | `ccv_dcu_mlc_probe_ack` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 22 | `ccv_fet_mlc_ifill` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 23 | `ccv_mlc_fet_ifill_rsp` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 24 | `ccv_miu_fet_itlb` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 25 | `ccv_fet_miu_itlb_req` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 26 | `ccv_mlc_exb_req` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 27 | `ccv_exb_mlc_rsp` | 1 × 1 | 1 | — | — | — | — | *false* | txn, none |
| 28 | `ccv_exb_ext_out` | 1 × 1 | 1 | — | — | — | — | *false* | txn |
| 29 | `ccv_rau_fet_launch` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 30 | `ccv_rau_ooe_alloc` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 31 | `ccv_ooe_rau_status` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 32 | `ccv_rau_ooe_demote` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 33 | `ccv_ooe_rau_drained` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 34 | `ccv_rau_rcu_mig` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 35 | `ccv_ooe_rcu_map` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 36 | `ccv_rcu_pca_mig` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 37 | `ccv_pca_rcu_mig` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 38 | `ccv_fet_pca_mig` | 1 × 1 | 1 | — | — | — | — | *false* | instr |
| 39 | `ccv_pca_fet_mig` | 1 × 1 | 1 | — | — | — | — | *false* | instr |
| 40 | `ccv_rau_fet_mig` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 41 | `ccv_pca_rau_mig_done` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 42 | `ccv_rau_pca_mig` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 43 | `ccv_miu_rau_ready` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 44 | `ccv_rau_miu_cta` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 45 | `ccv_ooe_syu_bar` | 1 × 1 | 1 | — | — | — | — | *false* | instr |
| 46 | `ccv_syu_ooe_rel` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 47 | `ccv_syu_fet_rel` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 48 | `ccv_syu_rau_ready` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 49 | `ccv_rau_syu_alloc` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 50 | `ccv_ooe_cru_fault` | 1 × 1 | 1 | — | — | — | — | *false* | instr |
| 51 | `ccv_cru_rau_cfg` | 1 × 1 | 1 | — | — | — | — | *false* | none |
| 52 | `ccv_ext_exb_in` | 1 × 1 | 1 | — | — | — | — | *false* | txn, none |
| 53 | `ccv_dcu_miu_fill_ntc` | 4 × 1 | 4 | *partial* | *free* | **none** — each notice names its refill by req_id, and its slot is its refill's | — | **true** — the promise counts cycles from the notice's landing, which means something only if MIU takes every notice the cycle it lands | txn |
| 54 | `ccv_miu_ooe_cmpl_hint` | 4 × 1 | 4 | *partial* | *free* | **none** — each hint names its completion by rob_tag, and its slot is its completion's | — | **true** — the promise counts cycles from the hint's landing, which means something only if OOE takes every hint the cycle it lands | instr |
