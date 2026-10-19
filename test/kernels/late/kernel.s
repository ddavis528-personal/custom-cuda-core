# late: an L1 hit too late for the contract (l1_late, A-46).
#
# a[i] = i for the first line. Two loads of a[tid], independent and issued
# back to back: the first misses and fills the line; the second finds it in
# L1 only after that fill, long past CCV_LAT_L1_CMPL, so MIU completes it as
# a miss (l1_late). A serialising MIU starts it after the first completes; a
# pipelined one sends it to DCU behind the fill. A third load, chasing the
# second's result, issues after it completes and hits on time (l1_hit).
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid] = tid: misses, fills the line
        LD_GLOBAL_IDX R3, R0, R1, 1, 0  # a[tid] again: behind the fill, late
        LD_GLOBAL_IDX R4, R0, R3, 1, 0  # a[tid] once more: hits on time
        C_ADD      R7, R2
        C_ADD      R7, R3
        C_ADD      R7, R4               # acc = 3 * tid
        C_EXIT     0
