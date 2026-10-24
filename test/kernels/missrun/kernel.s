# missrun: a load that misses, its dependants, and a run of independent work
# behind them that must issue under the miss (Daniel, 2026-10-21).
#
# a[i] = i at 0x30000. The load of a[tid] misses: its line comes from memory.
# Three adds chain on it, each waiting on the last, so the oldest unissued
# instructions are the chain. Behind it, ten pairs (MOVI, then C_ADD of tid)
# read nothing the load writes: an out-of-order OOE issues them during the
# miss, each ahead of the chain; an in-order one holds all twenty behind it.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid] = tid: a miss
        C_ADD      R2, R1               # 2 tid
        C_ADD      R2, R1               # 3 tid
        C_ADD      R2, R1               # 4 tid
        MOVI       R3, 3
        C_ADD      R3, R1
        MOVI       R4, 4
        C_ADD      R4, R1
        MOVI       R5, 5
        C_ADD      R5, R1
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
        MOVI       R12, 12
        C_ADD      R12, R1
        C_EXIT     0
