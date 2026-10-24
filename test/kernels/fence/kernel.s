# fence: a fence between a store and a load of the same words (IS-11). DEC
# decodes it as a memop of mem_kind fence, RCU sends MIU its (empty) address
# message, and MIU completes it once the warp's older store is written to DCU.
# One warp cannot observe that order; the barrier kernel, whose warps read
# each other's stores behind a fence, carries its control (TI-40).
        SRD        R1, 0                # tid
        MOVI48     R3, 3                # window 0x30000
        C_MOV      R2, R1               # a separate data register
        ST_GLOBAL_IDX R2, R3, R1, 1, 0  # [0x30000 + 4 tid] = tid
        C_FENCE    0
        LD_GLOBAL_IDX R4, R3, R1, 1, 0  # read it back
        C_EXIT     0
