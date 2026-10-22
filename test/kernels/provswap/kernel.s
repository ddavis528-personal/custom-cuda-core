# provswap: a provisional restore, demoted again when a ready warp wants its
# slot (AR's response TI-21, RAU spec rev 24). Six warps, four slots.
#
# Each warp runs pre[ctaid] iterations of a loop (0x50000), loads its 32
# words from its window, ptr[ctaid] at 0x20000, and runs cnt[ctaid] more
# (0x30000) that do not read them. Warp 0's window answers after 1,000
# cycles, warp 1's after 250, the others' at once. Warp 0 demotes on its
# miss and warp 4 launches into its slot; warp 1, a little later, demotes
# too, and warp 5 takes its slot. Warp 2 finishes first: with no launch
# pending and no parked warp ready, RAU restores warp 0 provisionally. Warp
# 1's fill lands long before warp 0's, so warp 1 is ready while every slot
# is full: warp 0, still waiting, demotes again, and warp 1 takes its slot.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 2                # ptr: window table 0x20000
        MOVI48     R14, 3               # cnt: loop table 0x30000
        MOVI48     R12, 5               # pre: loop table 0x50000
        SRD        R1, 0                # tid
        SRD        R2, 1                # ctaid
        LD_GLOBAL_IDX R3, R0, R2, 1, 0  # ptr[ctaid]: this warp's data window
        LD_GLOBAL_IDX R13, R14, R2, 1, 0  # cnt[ctaid]
        LD_GLOBAL_IDX R11, R12, R2, 1, 0  # pre[ctaid]
        MOVI       R7, 0                # i
        MOVI       R8, 1
Lpre:
        C_ADD      R7, R8               # i += 1
        SETP_LT    P1, R15, 0, R7, R11  # @P0 P1 = i < pre
        BRA_PRED   1, Lpre              # @P1 bra Lpre
        MOVI       R4, 32
        MADLO      R5, R2, R4, R1       # 32 ctaid + tid
        LD_GLOBAL_IDX R6, R3, R5, 1, 0  # warps 0 and 1: the slow lines
        C_ADD      R6, R1
        C_ADD      R6, R1               # a + 2 tid
        MOVI       R7, 0                # i
        MOVI       R9, 0                # acc
Lloop:
        C_ADD      R9, R1               # acc += tid
        C_ADD      R7, R8               # i += 1
        SETP_LT    P1, R15, 0, R7, R13  # @P0 P1 = i < cnt
        BRA_PRED   1, Lloop             # @P1 bra Lloop
        C_EXIT     0
