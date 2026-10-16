# hit: loads that hit in L1, each issued after the previous one completes.
#
# a[i] = i for the first line, so R2 = a[tid] = tid and every further load
# a[R] reads the same line again: the first load misses and fills it, and the
# rest are pointer-chasing L1 hits, each waiting on the one before. C_ADD
# reads each hit's result, so its dependants are woken by the L1 contract
# (CCV_LAT_L1_WAKE) once OOE speculates on hits. The last load is a different
# line, a[32 + tid], which misses.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid] = tid: misses, fills the line
        LD_GLOBAL_IDX R3, R0, R2, 1, 0  # a[tid]: hit
        C_ADD      R7, R3               # acc += tid
        LD_GLOBAL_IDX R4, R0, R3, 1, 0  # hit
        C_ADD      R7, R4
        LD_GLOBAL_IDX R5, R0, R4, 1, 0  # hit
        C_ADD      R7, R5
        LD_GLOBAL_IDX R6, R0, R5, 1, 0  # hit
        C_ADD      R7, R6               # acc = 4 * tid
        MOVI       R8, 32
        C_ADD      R8, R6               # 32 + tid
        LD_GLOBAL_IDX R9, R0, R8, 1, 0  # a[32 + tid]: another line, a miss
        C_ADD      R7, R9
        C_EXIT     0
