# byp: the lane-local bypass (A-59, TI-8). With OOE's bypass on
# (CCV_OOE_CONFIG=bypass=1) each dependant marked "forwards" issues
# CCV_LAT_LANE_BYP after its lane producer, before the result is in RCU's
# register file, and reads the value its own lane forwards: RCU names the
# producer's slot and age in operand_byp. With the bypass off it waits
# CCV_LAT_LANE and reads the register file, so the kernel passes either way.
#
# It reaches what the other kernels do not: a third operand forwarded
# (MADLO's addend). And it shows where the bypass stops: the masked load's
# copy-only op reads its old destination, the second C_ADD's result, as
# merge_data, a lane operand, but a memop and its copy issue only on
# confirmed sources (V-17), so the copy reads the register file even with
# the bypass on. RCU would forward to it as to any lane op.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 5                # window 0x50000
        SRD        R1, 0                # tid
        MOVI       R2, 16
        MOVI       R5, 100
        MOVI       R7, 7
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16: forwards tid
        C_ADD      R5, R1               # R5 = 100 + tid: forwards tid
        C_ADD      R7, R1               # R7 = 7 + tid: forwards tid
        C_ADD      R5, R1               # R5 = 100 + 2 tid: forwards R5
        MADLO      R6, R1, R2, R7       # R6 = 16 tid + 7 + tid: forwards R7, the third operand
        LD_GLOBAL_P R5, 1, R0, 0        # @P1 R5 = [0x50000]; the copy keeps 100 + 2 tid in lanes 16-31
        C_ADD      R6, R5               # reads the copied lanes
        C_EXIT     0
