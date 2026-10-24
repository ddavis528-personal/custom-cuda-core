# ldpar: younger loads that hit pass an older one that misses (Daniel,
# 2026-10-21).
#
# a[i] = i over two lines from 0x30000; b[i] = 100 + i at 0x40000. The first
# load of a warms line 0 of a. Once it is back, a load of b[tid] misses and
# an add waits on it. Behind them, four loads of a[tid] read the warm line:
# an out-of-order OOE issues each ahead of the add (and MIU completes them as
# hits under the miss); an in-order one holds them behind it.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        MOVI48     R9, 4                # b: window 0x40000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid]: warms a's line
        C_ADD      R3, R2               # waits for it, so the miss starts after
        LD_GLOBAL_IDX R4, R9, R3, 1, 0  # b[tid]: a miss
        C_ADD      R4, R1               # 100 + 2 tid, waiting on the miss
        LD_GLOBAL_IDX R5, R0, R1, 1, 0  # a[tid]: hits, ahead of the add
        LD_GLOBAL_IDX R6, R0, R1, 1, 0
        LD_GLOBAL_IDX R7, R0, R1, 1, 0
        LD_GLOBAL_IDX R8, R0, R1, 1, 0
        C_ADD      R5, R6
        C_ADD      R7, R8
        C_ADD      R5, R7               # 4 tid
        C_ADD      R4, R5               # 100 + 6 tid
        C_EXIT     0
