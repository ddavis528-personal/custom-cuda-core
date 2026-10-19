# late: L1 hits too late for the contract, and on time under a miss (A-46).
#
# a[i] = i for two lines. Two loads of a[tid], independent and issued back to
# back: the first misses and fills the line; the second finds it in L1 only
# after that fill, long past CCV_LAT_L1_CMPL, so MIU completes it as a miss
# (l1_late). A third, chasing the second's result, hits on time (l1_hit).
# Then a load of the second line misses, and one of the first line issues a
# cycle behind it, both waiting on R8: a pipelined MIU sends it to DCU while
# the miss is in flight, and it hits on time under it (hit_under_miss); a
# serialising one would hold it behind the miss, late.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid] = tid: misses, fills the line
        LD_GLOBAL_IDX R3, R0, R1, 1, 0  # a[tid] again: behind the fill, late
        LD_GLOBAL_IDX R4, R0, R3, 1, 0  # a[tid] once more: hits on time
        MOVI       R8, 32
        C_ADD      R8, R4               # 32 + tid, once the third load is back
        LD_GLOBAL_IDX R5, R0, R8, 1, 0  # a[32 + tid]: the second line, a miss
        LD_GLOBAL_IDX R6, R0, R8, 1, -128  # a[tid], behind it: a hit under the miss
        C_ADD      R7, R2
        C_ADD      R7, R3
        C_ADD      R7, R4
        C_ADD      R7, R5
        C_ADD      R7, R6               # acc = 5 * tid + 32
        C_EXIT     0
