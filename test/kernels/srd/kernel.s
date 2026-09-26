# srd: identity supplied by OOE, not by the oracle (Q-38).
#
# srd #0 (%ctatid) and srd #1 (%ctaid) run in the lane. OOE puts the value in
# the immediate from its shadow of RAU's warp-to-CTA table (ccv_rau_ooe_alloc),
# and the lane ORs its hardwired index in for selector 0. The CTA index is
# non-zero (kernel.cfg), so a wrong or missing %ctaid is visible: vadd and the
# other kernels all run CTA 0, where it reads as zero either way.
# Output: c[tid] = ctaid + tid, at 0x50000.
        MOVI48     R0, 5                # window 5 -> byte address 0x50000
        SRD        R1, 0                # %ctatid
        SRD        R2, 1                # %ctaid
        C_ADD      R2, R1               # ctaid + tid
        ST_GLOBAL_IDX R2, R0, R1, 1, 0  # c[tid]
        C_EXIT     0
