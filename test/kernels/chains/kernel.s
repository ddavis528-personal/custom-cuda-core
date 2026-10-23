# chains: a dependent chain, and independent work behind it that must not
# wait for it (Daniel, 2026-10-21: the kernels must force out-of-order issue).
#
# R2 gains tid eight times, each add reading the last: a chain of eight
# issues no faster than one add a lane latency.
# The eight pairs after it (MOVI, then C_ADD of tid) read nothing of R2's
# chain, so an out-of-order OOE issues them while the chain waits, ahead of
# older adds of R2; an in-order one holds every pair behind the chain's tail.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 1
        C_ADD      R2, R1               # 1 + 1 tid
        C_ADD      R2, R1               # 1 + 2 tid
        C_ADD      R2, R1               # 1 + 3 tid
        C_ADD      R2, R1               # 1 + 4 tid
        C_ADD      R2, R1               # 1 + 5 tid
        C_ADD      R2, R1               # 1 + 6 tid
        C_ADD      R2, R1               # 1 + 7 tid
        C_ADD      R2, R1               # 1 + 8 tid
        MOVI       R3, 3
        C_ADD      R3, R1               # tid + 3
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
        C_ADD      R2, R1               # 1 + 9 tid, after both
        C_EXIT     0
