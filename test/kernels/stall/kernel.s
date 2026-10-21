# stall: one warp stalled on a miss as long as DRAM's, three that are not
# (Daniel, 2026-10-21; TI-21). The others must fill the hole, not wait.
#
# Four warps, CTAs 0 to 3 (CTAS=4). Each reads its data window from a table,
# ptr[ctaid] at 0x20000: warp 0's is 8, the testbench's slow region
# (0x80000 and up answers after 400 cycles), the others' 4. Each loads its
# 32 words, a[32 ctaid + tid], chains four adds on them, and has eight
# independent pairs behind. Warp 0's chain waits out the slow line; warps 1
# to 3 share rename, the RS and issue with it, and must finish long before
# its line returns.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 2                # ptr: window 0x20000
        SRD        R1, 0                # tid
        SRD        R2, 1                # ctaid
        LD_GLOBAL_IDX R3, R0, R2, 1, 0  # ptr[ctaid]: this warp's data window
        MOVI       R4, 32
        MADLO      R5, R2, R4, R1       # 32 ctaid + tid
        LD_GLOBAL_IDX R6, R3, R5, 1, 0  # warp 0: the slow line
        C_ADD      R6, R1
        C_ADD      R6, R1
        C_ADD      R6, R1
        C_ADD      R6, R1               # a + 4 tid
        MOVI       R7, 7
        C_ADD      R7, R1
        MOVI       R8, 8
        C_ADD      R8, R1
        MOVI       R9, 9
        C_ADD      R9, R1
        MOVI       R10, 10
        C_ADD      R10, R1
        MOVI       R11, 11
        C_ADD      R11, R1
        MOVI       R12, 12
        C_ADD      R12, R1
        MOVI       R13, 13
        C_ADD      R13, R1
        MOVI       R14, 14
        C_ADD      R14, R1
        C_EXIT     0
