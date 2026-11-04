# pmovdiv: pmov.imm under a partial issue mask (RA-19; IS rev 183; ccv-sim
# at b83777e). P2 starts all ones; lanes 0-15 branch to Llow, where
# pmov.imm writes 0 to P2 on their lanes only, so lanes 16-31 keep theirs
# and P2 is 0xffff0000 after. RCU merges the old predicate's inactive lanes.
# --break pmov-all-lanes writes all 32 lanes, and the oracle's P2 refuses it.
        POR        P0, 4, 0             # P0 = all ones
        POR        P2, 4, 0             # P2 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 16
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        BRA_PRED   1, Llow              # @P1: lanes 0-15
        MOVI       R3, 200              # lanes 16-31
        BRA_PRED   0, Ljoin             # @P0: over the low half's code
Llow:
        PMOV_IMM   P2, 0                # lanes 0-15 only
        MOVI       R3, 100
Ljoin:
        C_ADD      R3, R1               # every lane again
        C_EXIT     0
