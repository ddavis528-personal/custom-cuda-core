# mlp: four iterations of a loop unrolled, each a load that misses and an add
# waiting on it (Daniel, 2026-10-21).
#
# a[i] = i over four lines from 0x30000. Iteration k loads a[32k + tid], a
# line of its own, so every load misses, and adds tid to it. A real loop
# would serialise here: FET predicts not taken, so each taken branch
# redirects (loop). Unrolled, each iteration's index and load read nothing of
# the iterations before, so an out-of-order OOE issues iteration k+1's load
# ahead of iteration k's add, and the misses overlap; an in-order one waits
# out each miss in turn.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid]: line 0, a miss
        C_ADD      R2, R1               # 2 tid
        MOVI       R3, 32
        C_ADD      R3, R1               # 32 + tid
        LD_GLOBAL_IDX R4, R0, R3, 1, 0  # line 1, a miss
        C_ADD      R4, R1               # 32 + 2 tid
        MOVI       R5, 64
        C_ADD      R5, R1
        LD_GLOBAL_IDX R6, R0, R5, 1, 0  # line 2
        C_ADD      R6, R1               # 64 + 2 tid
        MOVI       R7, 96
        C_ADD      R7, R1
        LD_GLOBAL_IDX R8, R0, R7, 1, 0  # line 3
        C_ADD      R8, R1               # 96 + 2 tid
        C_ADD      R2, R4
        C_ADD      R6, R8
        C_ADD      R2, R6               # 192 + 8 tid
        C_EXIT     0
