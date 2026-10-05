# brs: more unresolved branches than checkpoints, then a taken forward branch.
#
# Five branches FET predicts correctly (not taken) come back to back, but FET
# holds CCV_P_BR_CKPTS = 4 checkpoints per warp: the fifth waits for a
# resolution to free one on ccv_ooe_fet_ckpt_free. The last branch is taken
# by every lane, a mispredict that skips the MOVI.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 100
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 100: every lane
        BRA_PRED   5, Lskip             # @!P1: not taken
        BRA_PRED   5, Lskip
        BRA_PRED   5, Lskip
        BRA_PRED   5, Lskip
        BRA_PRED   5, Lskip
        BRA_PRED   1, Lskip             # @P1: taken by every lane
        MOVI       R6, 99               # skipped
Lskip:
        C_ADD      R1, R2
        C_EXIT     0
