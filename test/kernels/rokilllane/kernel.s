# rokilllane: rokill with lane ops in flight in RCU when the kill lands (RI-57,
# TI 452; RA's sign-off, M4's kernel margin). CTA 0 stores into the .const
# range and faults F-RO after a 40-pass wait of its own. CTAs 1-3 run a long loop of independent C_ADDs, four
# a pass, so the lanes always hold results not yet back in RCU's register
# file; the kill_lane bin proves one is in flight as the kill goes out. They
# never reach their exit, and the run ends with the eight owners' acks.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 1                # ctaid
        MOVI       R2, 1
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = ctaid < 1
        BRA_PRED   1, Lfault            # @P1: CTA 0
        SRD        R8, 0                # tid
        MOVI       R3, 0                # i
        MOVI       R4, 500              # n
        MOVI       R5, 1
        MOVI       R9, 0
        MOVI       R10, 0
        MOVI       R11, 0
        MOVI       R12, 0
Lloop:
        C_ADD      R9, R8               # four lane ops, none reading another
        C_ADD      R10, R8
        C_ADD      R11, R8
        C_ADD      R12, R8
        C_ADD      R3, R5
        SETP_LT    P1, R15, 0, R3, R4   # @P0 P1 = i < n
        BRA_PRED   1, Lloop
        C_EXIT     0
Lfault:
        MOVI       R3, 0                # CTA 0 waits 40 passes first, so CTAs
        MOVI       R4, 40               # 1-3 are deep in their loop when the
        MOVI       R5, 1                # fault retires
Lwait:
        C_ADD      R3, R5
        SETP_LT    P1, R15, 0, R3, R4   # @P0 P1 = i < 40
        BRA_PRED   1, Lwait
        MOVI48     R3, 5                # window 0x50000: .const
        SRD        R6, 0                # lane
        MOVI       R7, 77
        ST_GLOBAL_IDX R7, R3, R6, 1, 0  # [0x50000 + 4 lane] = 77: faults
        C_EXIT     0
