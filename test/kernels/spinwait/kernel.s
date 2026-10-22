# spinwait: one lane spins on a flag another lane sets (IS-17, O-60).
#
# CP's test/cuda/spinwait.cu (test/spinwait.s in the compiler snapshot) in
# the ops the skeleton's stubs carry: the same shape, with the flag and out
# at fixed windows rather than launch-block slots, whose _SLOT addressing
# MIU's stub does not form yet. Lanes 2-31 exit at once. Lane 0 spins at
# Lspin on the flag; lane 1 sets it at Lrelease, a higher PC. Under strict
# min-PC lane 0 is picked forever and the kernel hangs, which ccv-sim at
# -fairness=0 shows by running to its step limit (check-kernel's control).
# Under FET's rule lane 1's group is picked once lane r's group has gone
# CCV_FAIR_N picks without issuing: it writes out[1] = 7 and the flag, and
# lane 0 then sees the flag and writes out[0] = 1.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # window 0x30000: the flag
        MOVI48     R4, 5                # window 0x50000: out
        SRD        R1, 0                # lane
        MOVI       R2, 1
        MOVI       R3, 2
        MOVI       R7, 0
        SETP_LT    P1, R15, 0, R1, R3   # @P0 P1 = lane < 2
        BRA_PRED   5, Ldone             # @!P1: lanes 2-31 leave
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = lane < 1
        BRA_PRED   5, Lrelease          # @!P1: lane 1
        MOVI       R5, 0                # lane 0 counts its spins
Lspin:
        C_ADD      R5, R2
        LD_GLOBAL  R6, R0, 0            # the flag
        SETP_LT    P1, R15, 0, R6, R2   # @P0 P1 = flag < 1
        BRA_PRED   1, Lspin             # @P1: not yet
        ST_GLOBAL_IDX R2, R4, R7, 1, 0  # out[0] = 1
        C_EXIT     0
Lrelease:
        MOVI       R6, 7
        ST_GLOBAL_IDX R6, R4, R7, 1, 4  # out[1] = 7
        ST_GLOBAL_IDX R2, R0, R7, 1, 0  # flag = 1
Ldone:
        C_EXIT     0
