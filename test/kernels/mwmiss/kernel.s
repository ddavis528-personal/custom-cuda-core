# mwmiss: four warps, each a load that misses on a line of its own, its
# dependants, and independent work behind them (Daniel, 2026-10-21).
#
# a[i] = i over four lines from 0x30000. Warp w is CTA w (CTAS=4): it loads
# a[32 w + tid], which misses, chains two adds on it, and has six independent
# pairs behind. The four warps share rename, the RS and issue, so the other
# warps' work, and each warp's own pairs, issue while a warp's chain waits.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        SRD        R2, 1                # ctaid
        MOVI       R3, 32
        MADLO      R4, R2, R3, R1       # 32 ctaid + tid
        LD_GLOBAL_IDX R5, R0, R4, 1, 0  # a[32 ctaid + tid]: a miss, a line a warp
        C_ADD      R5, R1               # 32 ctaid + 2 tid
        C_ADD      R5, R1               # 32 ctaid + 3 tid
        MOVI       R6, 6
        C_ADD      R6, R1
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
        C_EXIT     0
