<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-trust-report.py. Edit a source and regenerate;
     tools/verify.sh fails if this file is stale. -->

# Trust report — which numbers are still made up

Generated. Every module referencing a width nobody has decided,
so this is a build artifact rather than something to remember.

| Tier | Meaning | What moves |
|---|---|---|
| `ccv_params_pkg` | follows from a settled decision | nothing |
| `ccv_prov_pkg` | a sizing placeholder | the number |
| `ccv_prelim_pkg` | no decided encoding at all | the field's shape |

## Direct references

| File | Preliminary | Provisional |
|---|---|---|
| `rtl/if/ccv_credit_checker.sv` | — | `CCV_P_TIMEOUT_N` |
| `test/neg/tb_credit_neg.sv` | — | `CCV_P_TIMEOUT_N` |
| `test/smoke/credit_smoke.sv` | — | `CCV_P_TIMEOUT_N` |

## Reach a source scan cannot see

A module that carries one of these payload structs depends on a
preliminary width without naming the package, so it does not
appear above. **23 of 46 channels** carry at least one
preliminary field:

| Channel | Preliminary fields |
|---|---|
| `ccv_cru_rau_cfg` | `kill_grid` |
| `ccv_dcu_mlc_req` | `coh_op` |
| `ccv_dec_ooe_uop` | `uop_class`, `opcode` |
| `ccv_exb_ext_out` | `tl_out` |
| `ccv_exb_mlc_rsp` | `probe_type` |
| `ccv_ext_exb_in` | `tl_in` |
| `ccv_fet_pca_mig` | `pcs` |
| `ccv_miu_dcu_req` | `coh_op` |
| `ccv_miu_fet_itlb` | `itlb_refill` |
| `ccv_miu_spm_req` | `spm_op` |
| `ccv_mlc_exb_req` | `coh_op`, `ownership_class` |
| `ccv_ooe_fet_redirect` | `group_masks` |
| `ccv_ooe_miu_memop` | `mem_op`, `space`, `ordering` |
| `ccv_ooe_rcu_issue` | `opcode` |
| `ccv_pca_fet_mig` | `pcs` |
| `ccv_pca_rcu_mig` | `pred_state` |
| `ccv_rau_fet_launch` | `code_bounds` |
| `ccv_rau_fet_mig` | `bank_select` |
| `ccv_rau_ooe_alloc` | `prf_base`, `prf_size` |
| `ccv_rau_rcu_mig` | `bank_select` |
| `ccv_rau_syu_alloc` | `barrier_count` |
| `ccv_rcu_lane_ops` | `opcode`, `operand` |
| `ccv_rcu_pca_mig` | `pred_state` |

## High-churn parameters

Churn rates the FIELD, not the number. **High** means a per-block
session is likely to change the field's shape, so code that
pattern-matches on its contents will need rewriting — as opposed
to code that merely carries it, which will not.

| Parameter | Value | Churn | Decided by |
|---|---|---|---|
| `CCV_L_OPERANDS_PER_LANE` | 3 | **HIGH** | RCU/LANE session -- see the src_arch vs operand mismatch |
| `CCV_L_PC_GROUPS` | 4 | **HIGH** | divergence model specification |
| `CCV_L_W_OPCODE` | 9 | **HIGH** | ISA opcode census, then DEC/OOE/RCU agree the hops |
| `CCV_L_W_PRED_STATE` | 1024 | **HIGH** | divergence model specification |
| `CCV_L_W_TL_IN` | 1176 | **HIGH** | EXB session -- flattened bundle or separate TL channels |
| `CCV_L_W_TL_OUT` | 1225 | **HIGH** | EXB session -- flattened bundle or separate TL channels |
| `CCV_L_W_COH_OP` | 4 | med | MLC/EXB session, once the TL-C subset is chosen |
| `CCV_L_W_CSR_ADDR` | 16 | med | CRU session -- the CSR fabric has no topology yet |
| `CCV_L_W_GRID_SEL` | 8 | med | RAU / CRU sessions |
| `CCV_L_W_MEM_OP` | 4 | med | MIU block session |
| `CCV_L_W_ORDERING` | 4 | med | OOE/MIU session -- is scope a separate field? |
| `CCV_L_W_OWNERSHIP` | 3 | med | MLC/EXB session, alongside CCV_L_W_COH_OP |
| `CCV_L_W_PCA_BANK` | 3 | med | PCA session, from the parked-array organization |
| `CCV_L_W_PRF_BASE` | 8 | med | RAU/OOE session -- register or chunk granularity |
| `CCV_L_W_PRF_SIZE` | 8 | med | RAU/OOE session, with CCV_L_W_PRF_BASE |
| `CCV_L_W_PROBE_TYPE` | 2 | med | MLC/EXB session, alongside CCV_L_W_COH_OP |
| `CCV_L_PAGE_SHIFT` | 12 | low | MMU session |
| `CCV_L_W_BAR_COUNT` | 7 | low | SYU session -- is the count biased? |
| `CCV_L_W_CLASS` | 3 | low | DEC block session -- is class derivable from opcode? |
| `CCV_L_W_ITLB_ENTRY` | 64 | low | MMU session, with the page-table format |
| `CCV_L_W_SPACE` | 3 | low | OOE/MIU session |
| `CCV_L_W_SPM_OP` | 2 | low | SPM block session |
