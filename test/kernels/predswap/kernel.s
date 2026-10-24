# predswap: two-predicate transfers, each cracked into two uops (TI-36), in
# a loop, for a demotion to land between an instruction's uops: the warp
# then resumes at the instruction and runs its first uop again, which both
# forms allow (AR's response TI-36). CCV_RAU_DEMOTE=at:<cycle> places it.
        SRD          R1, 0              # lane index
        MOVI48       R3, 9              # frame window
        MOVI         R5, 0              # i
        SETP_LT_NPI  P0, R14, R1, 8     # lanes 0-7
        SETP_LT_NPI  P1, R14, R1, 16    # lanes 0-15
loop:   ST_PRED_G    3, R3, 0           # P0, P1 out: two uops
        LD_PRED_G    3, R3, 0           # and back: two uops
        C_ADDI       R5, 1
        SETP_LT_NPI  P2, R14, R5, 8     # i < 8
        BRA_PRED     2, loop
        C_EXIT       0
