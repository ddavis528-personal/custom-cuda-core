# div: lanes that diverge and reconverge (IS-17, O-60).
#
# An if/else on tid: lanes 0-15 branch to Llow, lanes 16-31 fall through and
# branch over it, and both halves meet at Ljoin. Then a loop each lane runs
# tid + 1 times: at each backward branch one more lane leaves for the exit,
# so the loop group shrinks by a lane an iteration while the leavers wait at
# a higher PC. Min-PC keeps picking the loop, and FET's fairness rule picks
# the waiting group once lane r's group has gone CCV_FAIR_N picks without
# issuing, so lanes exit in several groups, not one.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 16
        MOVI       R4, 1
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        BRA_PRED   1, Llow              # @P1: lanes 0-15
        MOVI       R3, 200              # lanes 16-31
        C_ADD      R3, R1
        BRA_PRED   0, Ljoin             # @P0: over the low half's code
Llow:
        MOVI       R3, 100              # lanes 0-15
        C_ADD      R3, R1
Ljoin:
        C_ADD      R3, R4               # every lane again
        MOVI       R5, 0                # i
        MOVI       R7, 0                # acc
Lloop:
        C_ADD      R7, R3
        C_ADD      R5, R4               # i += 1
        SETP_LT    P1, R15, 0, R1, R5   # @P0 P1 = tid < i, so not yet for i <= tid
        BRA_PRED   5, Lloop             # @!P1: lanes with i <= tid go round
        C_EXIT     0
