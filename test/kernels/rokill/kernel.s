# rokill: a fatal fault kills the whole context (V-24, IS-2). Four CTAs,
# one warp each. CTA 0 stores into the .const range and faults F-RO. CTAs
# 1-3 run a long loop with no stores, still running when the fault retires,
# so RAU's kill must stop them: they never reach their exit, and the run
# ends with the eight owners' acks, every warp's state gone from them.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 1                # ctaid
        MOVI       R2, 1
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = ctaid < 1
        BRA_PRED   1, Lfault            # @P1: CTA 0
        MOVI       R3, 0                # i
        MOVI       R4, 500              # n
        MOVI       R5, 1
Lloop:
        C_ADD      R3, R5
        SETP_LT    P1, R15, 0, R3, R4   # @P0 P1 = i < n
        BRA_PRED   1, Lloop
        C_EXIT     0
Lfault:
        MOVI48     R3, 5                # window 0x50000: .const
        SRD        R6, 0                # lane
        MOVI       R7, 77
        ST_GLOBAL_IDX R7, R3, R6, 1, 0  # [0x50000 + 4 lane] = 77: faults
        C_EXIT     0
