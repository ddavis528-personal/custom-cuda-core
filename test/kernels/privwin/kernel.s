# privwin: O-83's private run (option W, DA tab rev 95; ISA v1.9 section 5.9),
# two warps of one CTA, hardware contexts 0 and 1. W = local_base + srd #3 is
# formed as compiled code forms it: an ordinary load of launch word 24,
# srd #3, an add. Every lane stores tid at word 0 and tid + 100 at word 1 of
# its own region, reads both back, and stores the sum to window 9 at 4 tid,
# an ordinary access. Then a group without lane 0: lanes 16-31 store
# tid + 1000 at word 2 through R5, which lanes 0-15 hold one window past the
# run. The decision is lane 16's, so the store is interleaved; taken on lane
# 0's rbase it would be ordinary, and land in the run's own window: F-ADDR.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid in the CTA
        MOVI       R13, 2               # the launch window
        LD_GLOBAL  R13, R13, 24         # local_base, launch word 24
        SRD        R2, 3                # %privoff = 3 * CCV_LANE_CONTEXTS
        C_ADD      R13, R2              # W, the run's base window
        ST_GLOBAL  R1, R13, 0           # word 0 of my region = tid
        MOVI       R3, 100
        C_ADD      R3, R1               # tid + 100
        ST_GLOBAL  R3, R13, 4           # word 1
        LD_GLOBAL  R4, R13, 0
        LD_GLOBAL  R5, R13, 4
        C_ADD      R4, R5               # 2 tid + 100
        MOVI48     R9, 9
        ST_GLOBAL_IDX R4, R9, R1, 1, 0  # [0x90000 + 4 tid]
        MOVI       R2, 16
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        MOVI       R12, 1
        MOVI       R6, 0
        ADD_P      R6, 1, R12, R14, R14 # @P1 R6 = 1; lanes 16-31 keep 0
        ADD        R5, R13, R6, R6      # W + 1 on lanes 0-15, W on 16-31
        BRA_PRED   1, Lskip             # @P1: lanes 0-15 skip the store
        MOVI       R7, 1000
        C_ADD      R7, R1               # tid + 1000
        ST_GLOBAL  R7, R5, 8            # lanes 16-31: word 2 of their region
Lskip:
        C_EXIT     0
