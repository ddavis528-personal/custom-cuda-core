# loop: a backward branch, taken 99 times and then not.
#
# FET predicts every branch not taken, so the loop branch mispredicts on each
# taken iteration: OOE redirects to the loop head, naming the checkpoint FET
# took, and FET restores it. The last resolution is correct, and frees its
# checkpoint on ccv_ooe_fet_ckpt_free. The two loop-carried registers take a
# fresh physical register every iteration, about 200 in all against a pool of
# 192, so the free list wraps and freed registers come back holding stale
# values.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 0                # i
        MOVI       R3, 100              # n
        MOVI       R4, 1
        MOVI       R5, 0                # acc
Lloop:
        C_ADD      R5, R1               # acc += tid
        C_ADD      R2, R4               # i += 1
        SETP_LT    P1, R15, 0, R2, R3   # @P0 P1 = i < n
        BRA_PRED   1, Lloop             # @P1 bra Lloop
        C_EXIT     0
